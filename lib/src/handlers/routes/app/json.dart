import 'dart:mirrors';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/errors/exp_res.dart';
import 'package:cruky/src/scanner/scanner.dart';

import '../abstract.dart';

class JsonHandler extends RouteHandler {
  final Function handler;
  JsonHandler(mock, accepted, this.handler)
      : super(mock, acceptedContentType: accepted);

  @override
  Future handle(Request req) async {
    var other = await req.json();
    try {
      return await handler(other);
    } on TypeError {
      return ERes.e406();
    }
  }

  static Future<JsonHandler?> parse(
    ClosureMirror handler,
    PipelineMock pipeline,
    List<String> acceptedContentType,
  ) async =>
      JsonHandler(
        pipeline,
        [MimeTypes.json],
        handler.reflectee,
      );

  static bool check(
    ClosureMirror handler,
    PipelineMock pipeline,
    List<String> accepted,
  ) {
    List<ParameterMirror> params = handler.function.parameters;
    if (params.length != 1) return false;
    if (params.first.type.isSubtypeOf(reflectType(Map))) {
      return true;
    }
    if (params.first.type.isSubtypeOf(reflectType(List))) {
      return true;
    }
    return false;
  }
}
