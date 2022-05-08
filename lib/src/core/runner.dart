library cruky.core.runner;

import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/common/ansicolor.dart';
import 'package:cruky/src/core/path_handler.dart';
import 'package:cruky/src/errors/liberrors.dart';
import 'package:cruky/src/scanner/scanner.dart';
import 'package:vm_service/vm_service.dart' hide Isolate;
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';

import 'server.dart';

/// ServerApp binded data
class _App {
  final bool debugMode;
  final ServerBind Function() init;
  final List<Future<void> Function()> onInit;
  final List<PathHandler> routesTree;

  _App({
    required this.init,
    required this.onInit,
    required this.debugMode,
    required this.routesTree,
  });
}

void runApp<T extends ServerApp>(T app,
    {int isolates = 2, bool debug = true}) async {
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
    onInit: inits,
    debugMode: debug,
    routesTree: routesTree,
  );
  if (debug) return _runAppInDebug(bindedApp, app);
  _runIsolatedApp(bindedApp);
  for (var i = 0; i < (isolates - 1); i++) {
    await Isolate.spawn(_runIsolatedApp, bindedApp);
  }
}

/// for running the app in isolates in production mode
void _runIsolatedApp(_App bindedApp) async {
  kIsDebug = bindedApp.debugMode;
  for (var item in bindedApp.onInit) {
    await item();
  }

  var server = CrukyServer(bindedApp.routesTree);
  ServerBind serverBind = bindedApp.init();
  server.serve(serverBind);

  var isolateID = Service.getIsolateID(Isolate.current);
  print('Listening on http://${serverBind.address}:${serverBind.port} '
      'served by isolate `$isolateID`');
}

/// for running app in debug mode
void _runAppInDebug(_App bindedApp, ServerApp app) async {
  kIsDebug = bindedApp.debugMode;

  var server = CrukyServer(bindedApp.routesTree);
  ServerBind serverBind = bindedApp.init();
  server.serve(serverBind);
  print('Listening on http://${serverBind.address}:${serverBind.port} '
      'in debug mode');
  try {
    await _watchDir(server, bindedApp, app, serverBind);
  } catch (e) {
    print('Did not find vm debugger on port `8181`'
        ' and the hot reloader will not run\n'
        'try to run `cruky serve dir/file.dart`');
  }
}

Future<void> _watchDir(
  CrukyServer server,
  _App bindedApp,
  ServerApp app,
  ServerBind serverBind,
) async {
  VmService serviceClient = await vmServiceConnectUri('ws://localhost:8181');
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
