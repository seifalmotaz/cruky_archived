library cruky.handlers;

import 'dart:io';

import 'package:cruky/src/core/req.dart';
import 'package:cruky/src/core/res.dart';

abstract class RouteHandler {
  // final List<String> accepted;
  final List<RouteHandler> pre = [];
  final List<RouteHandler> post = [];

  Future handle(Request req);

  Future<Response?> call(
    HttpRequest req,
    Map<String, dynamic> pathParams,
  ) async {
    Request reqCTX = Request(
      req: req,
      pathParams: pathParams,
      query: req.uri.queryParametersAll,
    );

    for (var item in pre) {
      final result = await item.handle(reqCTX);
      if (result != null) {
        return _handleResponse(result);
      }
    }

    final result = await handle(reqCTX);

    for (var item in post) {
      final result = await item.handle(reqCTX);
      if (result != null) {
        return _handleResponse(result);
      }
    }
    return _handleResponse(result);
  }

  Response? _handleResponse(result) {
    if (result is String) {
      return Text(result, 200);
    } else if (result is Map) {
      return Json(result, 200);
    }
    if (result is Response) return result;
    return null;
  }
}
