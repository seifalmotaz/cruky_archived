part of cruky.core.runner;

void multiRun(List<ServerApp> apps,
    {int isolates = 2, bool debug = true}) async {
  Map<ServerApp, _App> _apps = {};
  for (var app in apps) {
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
      name: app.name,
      debugMode: debug,
      routesTree: routesTree,
    );
    _apps.addAll({app: bindedApp});
  }
  if (debug) return multiRunInDebug(_apps);
  multiRunIsolated(_apps.values);
  for (var i = 0; i < (isolates - 1); i++) {
    Isolate.spawn(multiRunIsolated, _apps.values);
  }
}

/// for running the app in isolates in production mode
void multiRunIsolated(Iterable<_App> apps) async {
  kIsDebug = apps.first.debugMode;
  for (var app in apps) {
    for (var item in app.onInit) {
      await item();
    }

    var server = CrukyServer(app.routesTree);
    ServerBind serverBind = app.init();
    server.serve(serverBind);

    var isolateID = Service.getIsolateID(Isolate.current);
    print(
        '`${app.name}` Listening on http://${serverBind.address}:${serverBind.port} '
        'served by isolate `$isolateID`');
  }
}

void multiRunInDebug(Map<ServerApp, _App> apps) async {
  kIsDebug = apps.entries.first.value.debugMode;
  for (var entry in apps.entries) {
    var app = entry.key;
    var _app = entry.value;
    var server = CrukyServer(_app.routesTree);
    ServerBind serverBind = _app.init();
    server.serve(serverBind);
    print(
        '`${app.name}` Listening on http://${serverBind.address}:${serverBind.port} '
        'in debug mode');
    try {
      await watchDir(server, _app, app, serverBind);
    } catch (e) {
      print('Did not find vm debugger on port `8181`'
          ' and the hot reloader will not run\n'
          'try to run `cruky serve dir/file.dart`');
    }
  }
}
