import 'dart:mirrors';

import 'package:cruky/src/errors/liberrors.dart';
import 'package:cruky/src/handlers/middleware/main.dart';

class MiddlewareParser {
  List<Middleware> pre = [];
  List<Middleware> post = [];
  List<Function(ClosureMirror)> types = [DirectMiddleware.get];

  Future<void> parse(ClosureMirror mirror, bool isPre) async {
    for (var item in types) {
      var result = await item(mirror);
      if (result == null) continue;
      if (isPre) {
        pre.add(result);
      } else {
        post.add(result);
      }
      return;
    }
    throw LibError.stack(mirror.function.location!,
        'cruky does not support middleware of type ${mirror.reflectee}.');
  }
}
