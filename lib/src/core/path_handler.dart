import 'dart:io';
import 'package:cruky/src/common/path_pattern.dart';
import 'package:cruky/src/core/res.dart';
import 'package:cruky/src/errors/exp_res.dart';
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

  Future<void> call(HttpRequest req) async {
    try {
      req.response.headers.contentType = null;
      RouteHandler? handler = methods[req.method];
      if (handler == null) {
        ERes.e405().write(req);
        return;
      }
      Object? result = await handler(req, pattern.parseParams(req.uri.path));
      if (result != null) writeResponse(result, req);
    } catch (e, s) {
      if (e is ExpRes) {
        writeResponse(e.res, req);
        return;
      }
      print(e);
      print(s);
      ERes.e500().write(req);
    }
  }

  void writeResponse(Object result, HttpRequest req) async {
    try {
      if (result is String) {
        await Text(result).write(req);
        return;
      }
      if (result is List) {
        await Json(result).write(req);
        return;
      }
      if (result is Map) {
        if (result.containsKey(#status)) {
          result.removeWhere((key, value) => key is Symbol);
          await Json(result, result[#status]).write(req);
          return;
        }
        await Json(result).write(req);
        return;
      }
      if (result is Response) {
        await result.write(req);
        return;
      }
    } catch (e, s) {
      print(e);
      print(s);
      ERes.e500('Could not write a response').write(req);
    }
    return;
  }
}
