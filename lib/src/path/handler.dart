import 'dart:io';
import 'package:cruky/src/core/res.dart';
import 'package:cruky/src/errors/exp_res.dart';
import 'package:cruky/src/handlers/routes/abstract.dart';
import 'package:cruky/src/path/pattern.dart';
import 'package:cruky/src/request/req.dart';
import 'package:path/path.dart' as p;

class PathHandler {
  /// native splited path
  final String path;
  String get correctPath => "/$path/";

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
      RouteHandler? handler = methods[req.method] ?? methods['ANY'];
      if (handler == null) {
        ExpRes.e405().write(Request.pass(req));
        return;
      }
      Request reqCTX = Request(
        native: req,
        pathParams: pattern.parse(req.uri.path),
      );
      Object? result = await handler(reqCTX, pattern);
      if (result != null) writeResponse(result, reqCTX);
    } catch (e, s) {
      if (e is ExceptionResponse) {
        writeResponse(e.res, Request.pass(req));
        return;
      }
      print('');
      print(e);
      if (s.toString().isNotEmpty) print(s);
      ExpRes.e500().write(Request.pass(req));
    }
  }

  void writeResponse(Object result, Request req) async {
    // try {
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
    // } catch (e, s) {
    //   print(e);
    //   print(s);
    //   ExpRes.e500('Could not write a response').write(req);
    // }
    return;
  }
}

class StaticHandler extends PathHandler {
  final String parentDir;
  final List<String> filesURIs;
  StaticHandler({
    required this.parentDir,
    required this.filesURIs,
    required super.methods,
    required super.path,
    required super.pattern,
  });

  @override
  Future<void> call(HttpRequest req) async {
    try {
      String path;
      {
        Map<String, dynamic> parameters = pattern.parse(req.uri.path);
        path = parameters['path'];
        path = (path.split(RegExp(r"\/|\\"))..removeWhere((e) => e.isEmpty))
            .join('/');
      }
      Iterable<String> uri = filesURIs.where((e) => e.endsWith(path));
      if (uri.isEmpty) return writeResponse(ExpRes.e404(), Request.pass(req));
      writeResponse(FileStream(p.join(parentDir, path)), Request.pass(req));
    } catch (e, s) {
      if (e is ExceptionResponse) {
        return writeResponse(e.res, Request.pass(req));
      }
      print('');
      print(e);
      if (s.toString().isNotEmpty) print(s);
      return ExpRes.e500().write(Request.pass(req));
    }
  }
}
