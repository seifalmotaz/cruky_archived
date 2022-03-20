import 'dart:io';

import 'package:cruky/sr/handlers/handlers.dart';
import 'package:cruky/sr/helper/path_regex.dart';

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
  final RequestHandler methodHandler;
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
  dynamic handle(HttpRequest req) async => await methodHandler.handler(
        req: req,
        pathParams: path.parseParams(req.uri.path),
        pathQuery: req.uri.queryParameters,
      );
}
