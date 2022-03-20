import 'dart:convert';
import 'dart:io';

import 'dart:mirrors';

import 'annotiation.dart';
import 'handler/handlers.dart';
import 'helper/path_regex.dart';
import 'helper/print_req.dart';
import 'interfaces/request/request.dart';

Future<void> serve({String host = '127.0.0.1', int port = 5000}) async {
  Cruky server = Cruky(host, port);
  LibraryMirror mirror = currentMirrorSystem().isolate.rootLibrary;
  server.addLib(mirror);
  await server.serve();
}

class Cruky {
  String host;
  int port;
  Cruky([this.host = '127.0.0.1', this.port = 5000]);

  late HttpServer httpServer;
  final List<MethodHandler> routes = [];

  MethodHandler? match(String path, String method) {
    List<MethodHandler> _routes =
        routes.where((e) => e.match(path, method)).toList();
    if (_routes.isEmpty) return null;
    if (_routes.length == 1) {
      return _routes.first;
    } else {
      for (MethodHandler item in routes) {
        if (pathRegEx(path).regExp == item.path.regExp) return item;
      }
    }
    return null;
  }

  Future<void> serve({String? host_, int? port_}) async {
    httpServer = await HttpServer.bind(
      host_ ?? host,
      port_ ?? port,
      shared: true,
    );

    /// start server listen
    print('Server running on http://$host:$port');
    await for (HttpRequest req in httpServer) {
      MethodHandler? route = match(req.uri.path, req.method);
      if (route == null) {
        req.response.statusCode = 404;
      } else {
        dynamic res = await route.handle(req);
        req.response.headers.contentType = ContentType.json;
        if (res is Map) {
          req.response.statusCode = res[#status] ?? 200;
          res.removeWhere((key, value) => key is Symbol);
          req.response.write(jsonEncode(res));
        } else {
          req.response.write(jsonEncode(res));
        }
      }
      // close and print response and goto next request
      req.response.close();
      printReq(req);
    }
  }

  void passLib({Symbol? symbol, Uri? uri}) {
    if (symbol != null) addLib(currentMirrorSystem().findLibrary(symbol));
    if (uri != null) addLib(currentMirrorSystem().libraries[uri]!);
  }

  /// add library routes to routes
  void addLib(LibraryMirror lib) {
    /// get all declarations in library
    List<DeclarationMirror> declarations = lib.declarations.values.toList();
    for (var declaration in declarations) {
      /// check if it's a route handler method
      if (declaration.metadata
          .where((value) => value.reflectee is Route)
          .isEmpty) continue;
      if (declaration is MethodMirror) _addMethod(declaration, lib);
    }
  }

  void _addMethod(MethodMirror methodMirror, LibraryMirror lib) {
    late String method;
    late PathRegex path;

    /// get the required data to add the route to listener
    for (InstanceMirror item in methodMirror.metadata) {
      var reflectee = item.reflectee;
      if (reflectee is Route) {
        method = reflectee.method;
        path = pathRegEx(reflectee.path);
      }
    }

    /// get method required params
    List<ParameterMirror> paramsMI = methodMirror.parameters;

    ParameterMirror firstParam = paramsMI.first;
    routes.add(MethodHandler(
      method: method,
      path: path,
      requestType: firstParam.type.reflectedType,
      handler: lib.getField(methodMirror.simpleName).reflectee,
    ));
  }
}
