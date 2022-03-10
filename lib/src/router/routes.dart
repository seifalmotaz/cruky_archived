import 'dart:io';

import 'package:cruky/src/constants/header.dart';
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
  Map? validate(HttpRequest req);
  dynamic handle(HttpRequest req);
}

class MethodRoute extends RouteMatch {
  final ReqHeader contentType;
  final MethodHandler methodHandler;
  MethodRoute({
    required this.methodHandler,
    required PathRegex path,
    required String method,
    required this.contentType,
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
  Map? validate(HttpRequest req) {
    ContentType _contentType = req.headers.contentType ?? ContentType.json;
    if (_contentType.mimeType != contentType.contentType) {
      return {
        #status: 415,
        "msg": "Unsupported content type for resource.",
      };
    }
    return null;
  }

  @override
  dynamic handle(HttpRequest req) async => await methodHandler.handler(
        req: req,
        pathParams: path.parseParams(req.uri.path),
        contentType: contentType,
        pathQuery: req.uri.queryParameters,
      );
}
