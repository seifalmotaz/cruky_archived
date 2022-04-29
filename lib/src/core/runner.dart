library cruky.core.runner;

import 'dart:io';
import 'dart:isolate';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/common/ansicolor.dart';
import 'package:cruky/src/core/path_handler.dart';
import 'package:cruky/src/core/server.dart';
import 'package:cruky/src/errors/liberrors.dart';
import 'package:cruky/src/scanner/scanner.dart';
import 'package:vm_service/vm_service.dart' hide Isolate;
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';

void runApp<T extends ServerApp>(T app,
    {int isolates = 1, int listeners = 4}) async {
  late final List<PathHandler> routesTree;
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
  var data = IsolateData(app, routesTree, listeners, [], [], []);
  if (!app.debug) {
    runServer(IsolateData data) {
      kIsDebug = data.app.debug;
      var crukyServer = CrukyServer(data.routes);
      crukyServer.serve(data.address, data.port, data.listeners);
    }

    runServer(data);
    for (var i = 0; i < isolates; i++) {
      Isolate.spawn(runServer, data);
    }
    print('Server running on http://${app.address}:${app.port} '
        '$isolates*$listeners');
    while (true) {}
  } else {
    runInDebugMode(app, data);
  }
}

class IsolateData {
  final ServerApp app;
  final int listeners;
  final List<PathHandler> routes;
  final List<Function> onInit;
  final List<Function> onReady;
  final List<Function> onClose;
  String get address => app.address;
  int get port => app.port;
  IsolateData(
    this.app,
    this.routes,
    this.listeners,
    this.onInit,
    this.onReady,
    this.onClose,
  );
}

runInDebugMode(
  ServerApp app,
  IsolateData data,
) async {
  kIsDebug = data.app.debug;
  var server = CrukyServer(data.routes);
  server.serve(data.address, data.port, data.listeners);
  print('Server opened on http://${app.address}:${app.port} '
      'in debug mode');

  VmService serviceClient = await vmServiceConnectUri('ws://localhost:8181');
  var vm = await serviceClient.getVM();

  Future<void> watchDir(String dir) async {
    DirectoryWatcher(
      dir,
      pollingDelay: Duration(milliseconds: 1500),
    ).events.listen((event) async {
      print(success('_________________\nRestarting server'));
      server.close();
      for (var item in vm.isolates!) {
        await serviceClient.reloadSources(item.id!);
      }
      data.routes.clear();
      data.routes.addAll(await scan(app));
      server = CrukyServer(data.routes);
      server.serve(data.address, data.port, data.listeners);
      print('Server opened on http://${app.address}:${app.port} '
          'in debug mode');
    });
  }

  if (Directory('./bin/').existsSync()) watchDir('./bin/');
  if (Directory('./lib/').existsSync()) watchDir('./lib/');
  if (Directory('./test/').existsSync()) watchDir('./test/');
}
