library cruky.core.runner;

import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/common/ansicolor.dart';
import 'package:cruky/src/path/handler.dart';
import 'package:cruky/src/errors/liberrors.dart';
import 'package:cruky/src/scanner/scanner.dart';
import 'package:vm_service/vm_service.dart' hide Isolate;
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';

import 'server.dart';

/// ServerApp binded data
class _App {
  final String name;
  final bool debugMode;
  final bool printlogs;
  final ServerBind Function() init;
  final List<Future<void> Function()> onInit;
  final List<PathHandler> routesTree;

  _App({
    required this.init,
    required this.name,
    required this.onInit,
    required this.debugMode,
    required this.printlogs,
    required this.routesTree,
  });
}

void runApp(ServerApp app, {int isolates = 2, bool printlogs = true}) async {
  bool debug;
  {
    var serverUri = (await Service.getInfo()).serverUri;
    if (serverUri == null) {
      debug = false;
    } else {
      debug = true;
    }
  }

  final List<PathHandler> routesTree;
  try {
    routesTree = await scan(app);
  } catch (e) {
    if (e is LibError) {
      print(e.msg);
      print(e.stackTrace);
      return;
    }
    rethrow;
  }
  List<Future<void> Function()> inits = [];
  for (var item in app.plugins) {
    inits.add(item.onInit);
  }
  _App bindedApp = _App(
    init: app.init,
    name: app.name,
    onInit: inits,
    debugMode: debug,
    printlogs: printlogs,
    routesTree: routesTree,
  );
  if (debug) return runAppInDebug(bindedApp, app);
  runIsolatedApp(bindedApp);
  for (var i = 0; i < (isolates - 1); i++) {
    Isolate.spawn(runIsolatedApp, bindedApp);
  }
}

/// for running the app in isolates in production mode
void runIsolatedApp(_App bindedApp) async {
  kIsDebug = bindedApp.debugMode;
  printLogs = bindedApp.printlogs;
  for (var item in bindedApp.onInit) {
    await item();
  }

  var server = CrukyServer(bindedApp.routesTree);
  ServerBind serverBind = bindedApp.init();
  server.serve(serverBind);

  var isolateID = Service.getIsolateID(Isolate.current);
  print('[$isolateID] Listening on '
      'http://${serverBind.address}:${serverBind.port}');
}

/// for running app in debug mode
void runAppInDebug(_App bindedApp, ServerApp app) async {
  kIsDebug = bindedApp.debugMode;
  printLogs = bindedApp.printlogs;

  var server = CrukyServer(bindedApp.routesTree);
  ServerBind serverBind = bindedApp.init();
  server.serve(serverBind);
  print('Listening on http://${serverBind.address}:${serverBind.port} '
      'in debug mode');
  try {
    await watchDir(server, bindedApp, app, serverBind);
  } catch (e) {
    print('Did not find vm debugger on port `8181`'
        ' and the hot reloader will not run\n'
        'try to run `cruky serve dir/file.dart`');
  }
}

Future<void> watchDir(
  CrukyServer server,
  _App bindedApp,
  ServerApp app,
  ServerBind serverBind,
) async {
  String debugSocketURL = "ws://";
  {
    Uri uri = (await Service.getInfo()).serverUri!;
    debugSocketURL += "${uri.host}:";
    debugSocketURL += uri.port.toString();
    debugSocketURL += uri.path;
  }
  VmService serviceClient = await vmServiceConnectUri(debugSocketURL);
  var vm = await serviceClient.getVM();

  Future<void> watchDir(String dir) async {
    var events = DirectoryWatcher(dir).events;
    events.listen((event) async {
      print(success('_________________\nRestarting server'));
      server.close();
      for (var item in vm.isolates!) {
        await serviceClient.reloadSources(item.id!);
      }
      bindedApp.routesTree.clear();
      bindedApp.routesTree.addAll(await scan(app));
      server = CrukyServer(bindedApp.routesTree);
      server.serve(serverBind);
      print('Listening on http://${serverBind.address}:${serverBind.port} '
          'in debug mode');
    });
  }

  if (Directory('./bin/').existsSync()) watchDir('./bin/');
  if (Directory('./lib/').existsSync()) watchDir('./lib/');
  if (Directory('./test/').existsSync()) watchDir('./test/');
}
