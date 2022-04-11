library cruky.mw_filter;

import 'dart:mirrors';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/common/prototypes.dart';

/// return the middleware methods seperated beforeMW and afterMW
///
/// return a [Set] => {beforeMethods, afterMethods}
Set filterMW(List middlewares) {
  List<MethodMW> before = [];
  List<MethodMW> after = [];
  for (final item in middlewares) {
    bool isBefore = true;
    ClosureMirror mirror = reflect(item) as ClosureMirror;
    for (var meta in mirror.function.metadata) {
      if (meta.reflectee is AfterMW) {
        isBefore = false;
      } else if (meta.reflectee is BeforeMW) {
        isBefore = true;
      }
    }
    if (isBefore) before.add(item);
    if (!isBefore) after.add(item);
  }
  return {before, after};
}
