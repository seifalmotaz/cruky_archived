import 'dart:async';
import 'dart:io';
import 'dart:mirrors';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/errors/exp_res.dart';
import 'package:cruky/src/request/common/query.dart';
import 'package:cruky/src/request/req.dart';
import 'package:cruky/src/scanner/scanner.dart';

import 'abstract.dart';

class WebSocketHandler extends RouteHandler {
  final Function(WebSocket) handler;
  WebSocketHandler(mock, accepted, this.handler)
      : super(mock, acceptedContentType: accepted);

  @override
  Future handle(Request req) async {
    WebSocket socket = await WebSocketTransformer.upgrade(req.native);
    await handler(socket);
    return;
  }

  @override
  // ignore: invalid_override_of_non_virtual_member
  Future call(
    HttpRequest req,
    Map<String, dynamic> pathParams,
  ) async {
    if (!acceptedContentType.contains(req.headers.contentType?.mimeType) &&
        acceptedContentType.isNotEmpty) {
      return ERes.e415();
    }

    Request reqCTX = Request(
      native: req,
      path: pathParams,
      query: QueryParameters(req.uri),
    );

    for (var item in pre) {
      final _result = await item.handle(reqCTX);
      if (_result != null) {
        return _result;
      }
    }

    final result = await handle(reqCTX);
    return result;
  }

  static Future<WebSocketHandler?> parse(
    ClosureMirror handler,
    PipelineMock pipeline,
    List<String> acceptedContentType,
  ) async =>
      WebSocketHandler(
        pipeline,
        acceptedContentType,
        handler.reflectee,
      );

  static bool check(
    ClosureMirror handler,
    PipelineMock pipeline,
    List<String> accepted,
  ) {
    List<ParameterMirror> params = handler.function.parameters;
    if (params.length != 1) return false;
    if (params.first.type.reflectedType == WebSocket) {
      return true;
    }
    return false;
  }
}
