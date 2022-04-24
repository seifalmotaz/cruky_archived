import 'dart:mirrors';

import 'package:cruky/src/core/req.dart';
import 'package:cruky/src/handlers/middleware/main.dart';

import 'abstract.dart';

class DirectHandler extends RouteHandler {
  final Function(Request) handler;
  DirectHandler(this.handler);

  @override
  Future handle(Request req) async => await handler(req);

  static Future<DirectHandler?> parse(
      ClosureMirror handler, PipelineMock pipeline) async {
    try {
      handler.reflectee as Function(Request);
    } on TypeError {
      return null;
    }

    return DirectHandler(handler.reflectee)
      ..pre.addAll(pipeline.pre)
      ..post.addAll(pipeline.post);
  }
}
