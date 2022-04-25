library cruky.handlers;

import 'dart:io';

import 'package:cruky/src/request/req.dart';
import 'package:cruky/src/handlers/middleware/main.dart';
import 'package:meta/meta.dart';

abstract class RouteHandler {
  // final List<String> accepted;
  final List<Middleware> pre = [];
  final List<Middleware> post = [];

  Future handle(Request req);

  @nonVirtual
  Future call(
    HttpRequest req,
    Map<String, dynamic> pathParams,
  ) async {
    Request reqCTX = Request(
      req: req,
      pathParams: pathParams,
      query: req.uri.queryParametersAll,
    );

    for (var item in pre) {
      final _result = await item.handle(reqCTX);
      if (_result != null) {
        return _result;
      }
    }

    final result = await handle(reqCTX);

    for (var item in post) {
      final _result = await item.handle(reqCTX);
      if (_result != null) {
        return _result;
      }
    }
    return result;
  }
}
