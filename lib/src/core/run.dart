library cruky.core;

import 'dart:io';
import 'dart:mirrors';
import 'dart:isolate';

import 'package:ansicolor/ansicolor.dart';
import 'package:cruky/src/common/annotiations.dart';
import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/handlers/blank.dart';
import 'package:cruky/src/handlers/parser.dart';
import 'package:cruky/src/helpers/liberror.dart';
import 'package:cruky/src/interfaces/app_material/app_material.dart';
import 'package:cruky/src/interfaces/app_material/extentions.dart';
import 'package:cruky/src/interfaces/server_app.dart';
import 'package:cruky/src/server/server.dart';
import 'package:vm_service/vm_service.dart' hide Isolate;
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';

part 'parser.dart';

bool debugMode = true;
final AnsiPen greenPen = AnsiPen()..green();

late final List<HandlerType> _handlerTypes;

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
Future<void> runApp<T extends ServerApp>(T app, {bool debug = true}) async {
  debugMode = debug;
  _handlerTypes = app.handlerTypes;

  List<BlankRoute> routes = [];
  try {
    await _addRoutes(app, routes);
  } catch (e) {
    if (e is LibError) {
      print(e.msg);
      print(StackTrace.fromString(e.stackTrace));
      return;
    }
    rethrow;
  }

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
      'in debug mode');

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
      routes.clear();
      _addRoutes(app, routes);
      server = CrukyServer(routes);
      server.serve(
        address: app.address,
        port: app.port,
        threads: app.cores,
      );
      print('Server opened on http://${app.address}:${app.port} '
          'in debug mode');
    });
  }

  if (Directory('./bin/').existsSync()) watchDir('./bin/');
  if (Directory('./lib/').existsSync()) watchDir('./lib/');
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

Future<void> _addRoutes(app, List<BlankRoute> routes,
    [List<AppMaterial>? parents]) async {
  for (final route in app.routes) {
    // if (route is DirectHandler) {
    //   routes.add(_directRoute(route, parents ?? [app]));
    //   continue;
    // }
    if (route is AppMaterial) {
      routes.addAll(await _app(route, parents ?? [app]));
      continue;
    }
    // if (route is DirectRoute) {
    //   routes.add(route);
    //   continue;
    // }
    // if (route is List<Function>) {
    //   for (var item in route) {
    //     if (item is DirectHandler) {
    //       routes.add(_directRoute(item, parents ?? [app]));
    //       continue;
    //     }
    //   }
    //   continue;
    // }

    MethodParser parser = MethodParser(_handlerTypes);
    if (route is Function) {
      Map data = _methodData(route, parents ?? [app]);
      routes.add(await parser.parse(
        route,
        methods: data['methods'],
        path: data['path'],
        accepted: data['accepted'],
        afterMW: data['afterMW'],
        beforeMW: data['beforeMW'],
      ));
    }
  }
}

Future<List<BlankRoute>> _app(
    AppMaterial app, List<AppMaterial> parents) async {
  List<BlankRoute> routes = [];
  await _addRoutes(app, routes, [app, ...parents]);
  return routes;
}

Map _methodData(Function route, List<AppMaterial> apps) {
  late String path;
  late List<String> methods;
  List<MethodMW> beforeMW = [];
  List<MethodMW> afterMW = [];
  List acceptedRequests = [];
  ClosureMirror mirror = reflect(route) as ClosureMirror;

  List<InstanceMirror> metadata = mirror.function.metadata;
  for (InstanceMirror md in metadata) {
    final ref = md.reflectee;
    if (ref is Route) {
      Route expose = ref;
      path = expose.path;
      Set mws = filterMW(ref.middlewares);
      beforeMW += mws.first;
      afterMW += mws.last;
      methods = expose.methods
          .replaceAll(' ', '')
          .split(',')
          .map((e) => e.toUpperCase())
          .toList();
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

  return {
    'beforeMW': beforeMW,
    'afterMW': afterMW,
    'methods': methods,
    'path': path,
    'accepted': acceptedRequests,
  };
}

  // return  DirectRoute.parse(
  //   path: path,
  //   method: methods,
  //   handler: mirror.reflectee,
  //   beforeMW: beforeMW,
  //   afterMW: afterMW,
  //   accepted: acceptedRequests,
  // );
// }
