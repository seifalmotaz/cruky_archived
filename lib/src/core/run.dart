library cruky.core;

import 'dart:mirrors';

import 'package:cruky/src/common/annotiations.dart';
import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/handlers/direct.dart';
import 'package:cruky/src/interfaces/app_material/app_material.dart';
import 'package:cruky/src/interfaces/app_material/extentions.dart';
import 'package:cruky/src/server/server.dart';

part 'parser.dart';

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
void run<T extends AppMaterial>(
  T app, {
  String address = '127.0.0.1',
  int port = 5000,
  int threads = 5,
}) {
  List<DirectRoute> routes = [];
  _addRoutes(app, routes);
  CrukyServer server = CrukyServer(routes);
  server.serve(address: address, port: port, threads: threads);
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
