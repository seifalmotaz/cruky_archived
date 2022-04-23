import 'dart:io';

import 'package:cruky/src/common/path_pattern.dart';
import 'package:cruky/src/core/res.dart';
import 'package:cruky/src/errors/status_errors.dart';
import 'package:cruky/src/handlers/abstract.dart';

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

  Future<void> call(HttpRequest req) async {
    RouteHandler? handler = methods[req.method];
    if (handler == null) return StatusCode.e405(req);
    Response? result = await handler(req, pattern.parseParams(req.uri.path));
    if (result != null) await result.write(req);
    return req.response.close();
  }
}
