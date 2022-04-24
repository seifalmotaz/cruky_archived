import 'dart:io';

import 'package:cruky/src/common/path_pattern.dart';
import 'package:cruky/src/core/res.dart';
import 'package:cruky/src/errors/status_errors.dart';
import 'package:cruky/src/handlers/routes/abstract.dart';

class PathHandler {
  /// native splited path
  final String path;

  /// regex path for matching requests
  final PathPattern pattern;

  /// handlers sorted by methods
  final Map<String, RouteHandler> methods;

  PathHandler({
    required this.methods,
    required this.path,
    required this.pattern,
  });

  bool match(String p) => pattern.match(p);

  Future<void> call(HttpRequest req, StatusCodes statusHandler) async {
    RouteHandler? handler = methods[req.method];
    if (handler == null) return statusHandler.e405(req);
    Object? result = await handler(req, pattern.parseParams(req.uri.path));
    if (result != null) await writeResponse(result, req);
    return req.response.close();
  }

  Future<void> writeResponse(Object result, HttpRequest req) async {
    if (result is String) {
      await Text(result).write(req);
      return;
    }
    if (result is List) {
      await Json(result).write(req);
      return;
    }
    if (result is Map) {
      await Json(result).write(req);
      return;
    }
    if (result is Response) await result.write(req);
  }
}
