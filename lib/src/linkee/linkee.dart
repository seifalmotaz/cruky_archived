library linkee;

import 'package:cruco/src/interfaces/request.dart';

// import 'dart:mirrors';
// ClosureMirror mi = reflect(on) as ClosureMirror;
// MethodMirror  param = mi.function;

class Linkee {
  final String path;
  final String method;
  final List middlewares;
  Linkee(this.path, this.method, [this.middlewares = const []]);
}

class LinkeeMethod extends Linkee {
  final bool isAsync;
  final Function(CrucoRequest req) on;
  LinkeeMethod({
    required this.on,
    required this.isAsync,
    path,
    method,
    middlewares,
  }) : super(path, method, middlewares);
}
