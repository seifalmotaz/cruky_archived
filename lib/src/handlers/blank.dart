library cruky.handlers.blank;

import 'dart:io';

import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/helpers/path_parser.dart';
import 'package:cruky/src/request/request.dart';
import 'package:cruky/src/response/basic.dart';

class BlankRoute {
  final List<String> methods;
  final PathParser path;
  final List accepted;
  final List<MethodMW> beforeMW;
  final List<MethodMW> afterMW;
  BlankRoute({
    required this.path,
    required this.methods,
    required this.accepted,
    required this.beforeMW,
    required this.afterMW,
  });

  bool match(HttpRequest req) {
    if (!methods.contains(req.method)) return false;
    return path.match(req.uri.path);
  }

  Future handle(ReqCTX req) async => Json({});

  Future call(HttpRequest req) async {
    ReqCTX reqCTX = ReqCTX(
      native: req,
      path: req.uri,
      parameters: path.parseParams(req.uri.path),
      query: req.uri.queryParametersAll,
    );

    for (var item in beforeMW) {
      final result = await item(reqCTX);
      if (result != null) {
        return result;
      }
    }

    final result = await handle(reqCTX);

    for (var item in afterMW) {
      final result = await item(reqCTX);
      if (result != null) {
        return result;
      }
    }

    return result;
  }
}
