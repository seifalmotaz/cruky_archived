import 'dart:mirrors';

import 'package:cruky/src/core/req.dart';
import 'package:cruky/src/handlers/abstract.dart';

typedef BaseFunction = Function(Request);

class BaseHandler extends RouteHandler {
  final BaseFunction handler;
  BaseHandler(this.handler);

  @override
  Future handle(Request req) async {
    return await handler(req);
  }

  static Future<BaseHandler?> parse(
    ClosureMirror handler,
    List<RouteHandler> pre,
    List<RouteHandler> post,
  ) async {
    try {
      handler.reflectee as BaseFunction;
    } on TypeError {
      return null;
    }

    return BaseHandler(handler.reflectee)
      ..pre.addAll(pre)
      ..post.addAll(post);
  }
}
