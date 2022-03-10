import 'dart:convert';
import "dart:io";

import 'dart:mirrors';

import 'handlers/handlers.dart';
import 'helper/path_regex.dart';
import 'helper/print_req.dart';
import 'router/annotiation.dart';
import 'router/routes.dart';

Future<void> serve([String host = '127.0.0.1', int port = 5000]) async {
  Cruky server = Cruky(host, port);
  LibraryMirror mirror = currentMirrorSystem().isolate.rootLibrary;
  server.addLib(mirror);
  await server.serve();
}

class Cruky {
  String host;
  int port;
  Cruky([this.host = '127.0.0.1', this.port = 5000]);

  late HttpServer _httpServer;
  final List<RouteMatch> _routes = [];

  RouteMatch? match(String path, String method) {
    List<RouteMatch> routes =
        _routes.where((e) => e.match(path, method)).toList();
    if (routes.isEmpty) return null;
    if (routes.length == 1) {
      return routes.first;
    } else {
      for (RouteMatch item in routes) {
        if (pathRegEx(path).regExp == item.path.regExp) return item;
      }
    }
    return null;
  }

  Future<void> serve({String? host_, int? port_}) async {
    _httpServer = await HttpServer.bind(host_ ?? host, port_ ?? port);
    // start server listen
    print('Server running on http://$host:$port');
    await for (HttpRequest req in _httpServer) {
      // get the request handler
      RouteMatch? route = match(req.uri.path, req.method);
      if (route != null) {
        dynamic res = await route.handle(req);
        req.response.headers.contentType = ContentType.json;
        if (res is Map) {
          req.response.statusCode = res[#status] ?? 200;
          res.removeWhere((key, value) => key is Symbol);
          req.response.write(jsonEncode(res));
        } else {
          req.response.write(jsonEncode(res));
        }
      } else {
        req.response.statusCode = 404;
      }
      // close and print response and goto next request
      req.response.close();
      printReq(req);
    }
  }

  void passLib({Symbol? symbol}) {
    if (symbol != null) addLib(currentMirrorSystem().findLibrary(symbol));
  }

  void addLib(LibraryMirror lib) {
    List<DeclarationMirror> declarations = lib.declarations.values.toList();
    for (var declaration in declarations) {
      if (declaration.metadata
          .where((value) => value.reflectee is Route)
          .isEmpty) continue;
      if (declaration is MethodMirror) _addMethod(declaration);
      // if (declaration is ClassMirror) _addClass(declaration);
    }
  }

  void _addMethod(MethodMirror declaration) {
    late String method;
    late PathRegex path;
    for (InstanceMirror item in declaration.metadata) {
      var reflectee = item.reflectee;
      if (reflectee is Route) {
        method = reflectee.method;
        path = pathRegEx(reflectee.path);
      }
    }
    List<ParameterMirror> paramsMI = declaration.parameters.toList();
    Map<String, Type> params = {};
    for (ParameterMirror parm in paramsMI) {
      params.addAll({
        MirrorSystem.getName(parm.simpleName): parm.type.reflectedType,
      });
    }
    _routes.add(MethodRoute(
      path: path,
      method: method,
      methodHandler: MethodHandler(
        declaration.owner!.simpleName,
        declaration.simpleName,
        params,
      ),
    ));
  }
}
