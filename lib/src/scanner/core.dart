library cruky.scanner;

import 'dart:mirrors';

import 'package:cruky/src/annotation.dart';
import 'package:cruky/src/errors/liberrors.dart';
import 'package:cruky/src/common/path_pattern.dart';
import 'package:cruky/src/core/path_handler.dart';
import 'package:cruky/src/handlers/abstract.dart';
import 'package:cruky/src/handlers/base.dart';
import 'package:cruky/src/interfaces.dart';

part './routes_mirrors.dart';
part 'method_parser.dart';

/// this function helps you to run the main server app
///
/// __isolates__ number of isolates to run http servers
///
/// __cores__ number of http server in every single isolate
Future<List<PathHandler>> scan<T extends ServerApp>(T app) async {
  // preparing routes, app plugins and middleware
  final List<RouteMock> unsortedRoutes = [];
  try {
    final List<RouteMirror> routesMirrors = [];
    routesMirrors.addAll(getRoutesMirrors(app));

    MethodParser parser = MethodParser([]);
    for (var r in routesMirrors) {
      await parser.addAll(r);
    }

    unsortedRoutes.addAll(parser.list);
  } catch (e) {
    if (e is LibError) {
      print(e.msg);
      print(StackTrace.fromString(e.stackTrace));
      throw '\n${e.msg}';
    }
    rethrow;
  }

  // let's sort this routes and create routes tree
  unsortedRoutes.sort((a, b) => a.path.compareTo(b.path));
  final List<List<RouteMock>> sublists = []; // sorted routes by path
  {
    // sorting
    String? path;
    List<RouteMock> list = [];
    for (var i = 0; i <= unsortedRoutes.length; i++) {
      if (i == unsortedRoutes.length) {
        if (list.isNotEmpty) sublists.add(list);
        continue;
      }
      var route = unsortedRoutes[i];
      if (path == null) {
        path = route.path;
        list = [route];
      } else {
        if (route.path == path) {
          list.add(route);
        } else {
          if (list.isNotEmpty) sublists.add(list);
          path = route.path;
          list = [route];
        }
      }
    }
  }

  // final result of routes tree
  final List<PathHandler> routesTree = [];

  for (var routeList in sublists) {
    String path = routeList.first.path;
    final Map<String, RouteHandler> methods = {};
    for (var route in routeList) {
      for (var i in route.methods) {
        methods[i] = route.handler;
      }
    }
    routesTree.add(PathHandler(
      methods: methods,
      path: path,
      pattern: PathPattern.parse(path),
    ));
  }
  return routesTree;
}
