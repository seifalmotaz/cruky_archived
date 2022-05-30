import 'dart:async';
import 'dart:mirrors';

import 'package:cruky/src/request/req.dart';
import 'package:cruky/src/scanner/scanner.dart';

import 'abstract.dart';

class DirectHandler extends RouteHandler {
  final Function(Request) handler;
  DirectHandler(super.mock, super.acceptedContentType, this.handler);

  @override
  Future handle(Request req) async => await handler(req);

  static Future<DirectHandler?> parse(
    ClosureMirror handler,
    PipelineMock pipeline,
    List<String> acceptedContentType,
  ) async =>
      DirectHandler(
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
    if (params.first.type.reflectedType == Request) {
      return true;
    }
    return false;
  }
}
