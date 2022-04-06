library cruky.core;

import 'dart:io';
import 'dart:mirrors';
import 'dart:isolate';

import 'package:ansicolor/ansicolor.dart';
import 'package:cruky/src/common/annotiations.dart';
import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/handlers/direct.dart';
import 'package:cruky/src/interfaces/app_material/app_material.dart';
import 'package:cruky/src/interfaces/app_material/extentions.dart';
import 'package:cruky/src/interfaces/app_material/server_app.dart';
import 'package:cruky/src/server/server.dart';
import 'package:vm_service/vm_service.dart' hide Isolate;
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';

part 'parser.dart';

bool debugMode = true;
final AnsiPen greenPen = AnsiPen()..green();

/// This helps you to to add all app to the routes tree in the server.
///
/// ```
/// void main() => run(MyApp());
///
/// class MyApp extends AppMaterial {
///   @override
///   String get prefix => '/prefix'; // default is '/'
///
///   @override
///   List get routes => [
///         example,
///       ];
/// }
///
/// @Route.get('/')
/// example(ReqCTX req) {
///   return JsonRes({'example': 'route'});
/// }
/// ```
Future<void> run<T extends ServerApp>({bool debug = true}) async {
  debugMode = debug;

  ClassMirror mirror = reflectClass(T);
  ServerApp app = mirror.newInstance(Symbol.empty, []).reflectee;

  List<DirectRoute> routes = [];
  _addRoutes(app, routes);

  if (!debugMode) {
    for (var i = 0; i < app.isolates; i++) {
      Isolate.spawn(runServer, [routes, app]);
    }
    print('Server opened on http://${app.address}:${app.port} '
        'with ${app.isolates} isolates');
    while (true) {}
  }

  CrukyServer server = CrukyServer(routes);
  server.serve(
    address: app.address,
    port: app.port,
    threads: app.cores,
  );
  print('Server opened on http://${app.address}:${app.port} '
      'with ${app.isolates} isolates');
  VmService serviceClient = await vmServiceConnectUri('ws://localhost:8181');
  var vm = await serviceClient.getVM();

  Future<void> watchDir(String dir) async {
    DirectoryWatcher(
      dir,
      pollingDelay: Duration(milliseconds: 1500),
    ).events.listen((event) async {
      print(greenPen('_________________\nRestarting server'));
      await server.close();
      for (var item in vm.isolates!) {
        await serviceClient.reloadSources(item.id!);
      }
      app = mirror.newInstance(Symbol.empty, []).reflectee;
      routes.clear();
      _addRoutes(app, routes);
      server = CrukyServer(routes);
      server.serve(
        address: app.address,
        port: app.port,
        threads: app.cores,
      );
      print('Server opened on http://${app.address}:${app.port} '
          'with ${app.isolates} isolates');
    });
  }

  watchDir('./bin/');
  watchDir('./lib/');
  if (Directory('./test/').existsSync()) watchDir('./test/');
}

void runServer(List data) {
  CrukyServer server = CrukyServer(data.first);
  server.serve(
    address: data.last.address,
    port: data.last.port,
    threads: data.last.cores,
  );
}

void _addRoutes(app, List<DirectRoute> routes, [List<AppMaterial>? parents]) {
  for (final route in app.routes) {
    if (route is DirectHandler) {
      routes.add(_directRoute(route, parents ?? [app]));
      continue;
    }
    if (route is AppMaterial) {
      routes.addAll(_app(route, parents ?? [app]));
      continue;
    }
    if (route is DirectRoute) {
      routes.add(route);
      continue;
    }
    if (route is List<Function>) {
      for (var item in route) {
        if (item is DirectHandler) {
          routes.add(_directRoute(item, parents ?? [app]));
          continue;
        }
      }
      continue;
    }
  }
}

List<DirectRoute> _app(AppMaterial app, List<AppMaterial> parents) {
  List<DirectRoute> routes = [];
  _addRoutes(app, routes, [app, ...parents]);
  return routes;
}

DirectRoute _directRoute(DirectHandler route, List<AppMaterial> apps) {
  late String path;
  late String methods;
  List beforeMW = [];
  List afterMW = [];
  List acceptedRequests = [];
  ClosureMirror mirror = reflect(route) as ClosureMirror;

  List<InstanceMirror> metadata = mirror.function.metadata;
  for (InstanceMirror md in metadata) {
    final ref = md.reflectee;
    if (ref is Route) {
      Route expose = ref;
      path = expose.path;
      methods = expose.methods;
      Set mws = filterMW(ref.middlewares);
      beforeMW += mws.first;
      afterMW += mws.last;
    }
  }

  for (final app in apps) {
    path = ((app.prefix.split('/') + path.split('/'))
          ..removeWhere((e) => e.isEmpty))
        .join('/');
    Set mws = filterMW(app.middlewares);
    beforeMW += mws.first;
    afterMW += mws.last;
    acceptedRequests += app.accepted;
  }

  return DirectRoute.parse(
    path: path,
    method: methods,
    handler: mirror.reflectee,
    beforeMW: beforeMW,
    afterMW: afterMW,
    accepted: acceptedRequests,
  );
}
