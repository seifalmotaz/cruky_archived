import 'dart:convert';
import 'dart:io';

import 'dart:mirrors';

import 'package:cruky/src/interfaces/request/request.dart';

import 'annotiation.dart';
import 'handler/handlers.dart';
import 'helper/method_param.dart';
import 'helper/path_regex.dart';
import 'helper/print_req.dart';

/// init the  server app with cruky
///
/// ```dart
/// Cruky app = Cruky();
/// or
/// Cruky app = Cruky(customHost, customPort);
///
/// // adding the HttpServer.bind()
/// await app.bind();
/// // start server
/// app.serve();
/// ```
class Cruky {
  String host;
  int port;
  Cruky([this.host = '127.0.0.1', this.port = 5000]);

  HttpServer? httpServer;
  final List<MethodHandler> routes = [];

  MethodHandler? _match(String path, String method) {
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

  bool get isListening => httpServer != null;

  Future<void> close() async {
    await httpServer?.close(force: true);
    httpServer = null;
    print('Server closed');
  }

  /// binding HttpServer
  bind({String? host_, int? port_}) async {
    httpServer = await HttpServer.bind(
      host_ ?? host,
      port_ ?? port,
      shared: true,
    );
  }

  /// start server listening
  Future<void> serve() async {
    /// start server listen
    print('Server running on http://$host:$port');
    await for (HttpRequest req in httpServer!) {
      MethodHandler? route = _match(req.uri.path, req.method);

      if (route == null) {
        req.response.statusCode = 404;
      } else {
        dynamic res = await route.handle(req);
        req.response.headers.contentType = ContentType.json;
        if (res is Map) {
          req.response.statusCode = res[#status] ?? 200;
          dynamic body = res[#body];
          if (body != null) {
            req.response.write(jsonEncode(body));
          } else {
            res.removeWhere((key, value) => key is Symbol);
            req.response.write(jsonEncode(res));
          }
        } else {
          req.response.write(jsonEncode(res));
        }
      }
      // close and print response and goto next request
      req.response.close();
      printReq(req);
    }
  }

  /// adding library to server routes with symbol or uri
  /// ```dart
  /// Cruky().passLib(#todoLibrary)
  /// ```
  void passLib(Symbol symbol) =>
      _addLib(currentMirrorSystem().findLibrary(symbol));

  /// add library routes to routes
  void _addLib(LibraryMirror lib) {
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
    bool isDirect = false;
    late String method;
    late PathRegex path;
    Type? requestType;

    /// get the required data to add the route to listener
    for (InstanceMirror item in methodMirror.metadata) {
      var reflectee = item.reflectee;
      if (reflectee is Route) {
        method = reflectee.method;
        path = pathRegEx(reflectee.path, endWith: true);
        requestType = reflectee.contentType;
      }
    }

    /// get method required params
    MethodParams methodParams = MethodParams();
    List<ParameterMirror> paramsMI = methodMirror.parameters;

    final simpleRequestReflect = reflectType(SimpleRequest);
    for (ParameterMirror param in paramsMI) {
      if (requestType == null) {
        TypeMirror paramType = param.type;
        if (paramType.isSubtypeOf(simpleRequestReflect)) {
          requestType = param.type.reflectedType;
          if (paramsMI.length == 1) isDirect = true;
          continue;
        }
      }
      methodParams.add(param);
    }

    if (isDirect) {
      routes.add(DirectHandler(
        path: path,
        method: method,
        requestType: requestType,
        handler: lib.getField(methodMirror.simpleName).reflectee,
      ));
    } else {
      routes.add(InDirectHandler(
        path: path,
        method: method,
        params: methodParams.list,
        name: methodMirror.simpleName,
        handler: lib.invoke,
        requestType: requestType ?? methodParams.requestContentType,
      ));
    }
  }
}
