import 'dart:mirrors';

import 'package:cruky/cruky.dart';

/// return the middleware methods seperated beforeMW and afterMW
///
/// return a [Set] => {beforeMethods, afterMethods}
Set filterMW(List middlewares) {
  List before = [];
  List after = [];
  for (final item in middlewares) {
    bool isBefore = true;
    ClosureMirror mirror = reflect(item) as ClosureMirror;
    for (var meta in mirror.function.metadata) {
      if (meta.reflectee is MiddlewareAfter) {
        isBefore = false;
      } else if (meta.reflectee is MiddlewareBefore) {
        isBefore = true;
      }
    }
    if (isBefore) before.add(item);
    if (!isBefore) after.add(item);
  }
  return {before, after};
}
