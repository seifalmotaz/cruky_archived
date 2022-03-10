import 'dart:io';

import 'package:cruky/src/handlers/handlers.dart';
import 'package:cruky/src/helper/path_regex.dart';

/// route matching handler that have the method handler
abstract class RouteMatch {
  PathRegex path;
  String method;
  RouteMatch({
    required this.path,
    required this.method,
  });

  bool match(String _path, String _method);
  dynamic handle(HttpRequest req);
}

class MethodRoute extends RouteMatch {
  final MethodHandler methodHandler;
  MethodRoute({
    required this.methodHandler,
    required PathRegex path,
    required String method,
  }) : super(
          path: path,
          method: method,
        );

  @override
  bool match(String _path, String _method) {
    if (_method != method) return false;
    return path.match(_path);
  }

  @override
  dynamic handle(HttpRequest req) async =>
      await methodHandler.handler(req, path.parseParams(req.uri.path));
}
