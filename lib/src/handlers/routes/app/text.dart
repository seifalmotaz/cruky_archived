import 'dart:convert';
import 'dart:mirrors';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/scanner/scanner.dart';

import '../abstract.dart';

class TextHandler extends RouteHandler {
  final Function(String) handler;
  TextHandler(mock, accepted, this.handler)
      : super(mock, acceptedContentType: accepted);

  @override
  Future handle(Request req) async {
    return await handler(await utf8.decodeStream(req.native));
  }

  static Future<TextHandler?> parse(
    ClosureMirror handler,
    PipelineMock pipeline,
    List<String> acceptedContentType,
  ) async =>
      TextHandler(
        pipeline,
        [MimeTypes.txt],
        handler.reflectee,
      );

  static bool check(
    ClosureMirror handler,
    PipelineMock pipeline,
    List<String> accepted,
  ) {
    List<ParameterMirror> params = handler.function.parameters;
    if (params.length != 1) return false;
    if (params.first.type.reflectedType == String) {
      return true;
    }
    return false;
  }
}
