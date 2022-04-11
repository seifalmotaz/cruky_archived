library cruky.core;

import 'dart:io';
import 'dart:mirrors';
import 'dart:isolate';

import 'package:ansicolor/ansicolor.dart';
import 'package:cruky/cruky.dart';
import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/handlers/blank.dart';
import 'package:cruky/src/handlers/parser.dart';
import 'package:cruky/src/helpers/liberror.dart';
import 'package:cruky/src/helpers/mw_filter.dart';
import 'package:cruky/src/server/server.dart';
import 'package:vm_service/vm_service.dart' hide Isolate;
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';

part 'parser.dart';

final AnsiPen greenPen = AnsiPen()..green();

late final Map<Type?, HandlerType> _handlerTypes = {};

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

  for (var item in app.handlerTypes) {
    _handlerTypes.addAll({item.annotiationType: item});
  }

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

  final List<Function()> onlisten = [];
  onlisten.add(app.onlisten);

  for (PluginApp plugin in app.plugins) {
    for (var item in plugin.handlerTypes) {
      _handlerTypes.addAll({item.annotiationType: item});
    }
    await _addRoutes(plugin, routes);
    onlisten.add(plugin.onlisten);
  }

  _DataParser _dataParser = _DataParser(app, routes, onlisten);
  if (!debugMode) {
    for (var i = 0; i < app.isolates; i++) {
      Isolate.spawn(runServer, _dataParser);
    }
    print('Server opened on http://${app.address}:${app.port} '
        'with ${app.isolates} isolates');
    while (true) {}
  }

  Isolate.spawn(runServerDebug, _dataParser);
  while (true) {}
}

Future<void> runServerDebug(_DataParser msg) async {
  for (var i in msg.onlisten) {
    await i();
  }
  CrukyServer server = CrukyServer(msg.routes);
  server.serve(
    address: msg.app.address,
    port: msg.app.port,
    threads: msg.app.cores,
  );
  print('Server opened on http://${msg.app.address}:${msg.app.port} '
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
      msg.routes.clear();
      _addRoutes(msg.app, msg.routes);
      server = CrukyServer(msg.routes);
      server.serve(
        address: msg.app.address,
        port: msg.app.port,
        threads: msg.app.cores,
      );
      print('Server opened on http://${msg.app.address}:${msg.app.port} '
          'in debug mode');
    });
  }

  if (Directory('./bin/').existsSync()) watchDir('./bin/');
  if (Directory('./lib/').existsSync()) watchDir('./lib/');
  if (Directory('./test/').existsSync()) watchDir('./test/');
}

Future<void> runServer(_DataParser msg) async {
  msg.onlisten.map((e) async => await e());
  CrukyServer server = CrukyServer(msg.routes);
  server.serve(
    address: msg.app.address,
    port: msg.app.port,
    threads: msg.app.cores,
  );
}

Future<void> _addRoutes(app, List<BlankRoute> routes,
    [List<AppMaterial>? parents]) async {
  for (final route in app.routes) {
    if (route is AppMaterial) {
      routes.addAll(await _app(route, parents ?? [app]));
      continue;
    }

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
    if (route is List<Function>) {
      for (var item in route) {
        Map data = _methodData(item, parents ?? [app]);
        routes.add(await parser.parse(
          item,
          methods: data['methods'],
          path: data['path'],
          accepted: data['accepted'],
          afterMW: data['afterMW'],
          beforeMW: data['beforeMW'],
        ));
      }
      continue;
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

class _DataParser {
  final ServerApp app;
  final List<BlankRoute> routes;
  final List<Function()> onlisten;
  _DataParser(this.app, this.routes, this.onlisten);
}
