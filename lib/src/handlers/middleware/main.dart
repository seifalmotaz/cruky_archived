import 'dart:mirrors';

import 'package:cruky/src/request/req.dart';

abstract class Middleware {
  Future handle(Request req);
}

class DirectMiddleware extends Middleware {
  final Function(Request) handler;
  DirectMiddleware(this.handler);

  @override
  Future handle(Request req) async => await handler(req);

  static DirectMiddleware? get(ClosureMirror mirror) {
    try {
      mirror.reflectee as Function(Request);
    } on TypeError {
      print('object');
      return null;
    }
    return DirectMiddleware(mirror.reflectee);
  }
}
