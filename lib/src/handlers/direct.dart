import 'dart:io';

import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/params/path_parser.dart';

class BlankRoute {
  final List<String> methods;
  final PathParser path;
  final List accepted;
  final List beforeMW;
  final List afterMW;
  BlankRoute({
    required this.path,
    required this.methods,
    required this.accepted,
    required this.beforeMW,
    required this.afterMW,
  });
}

class DirectRoute extends BlankRoute {
  final DirectHandler handler;

  DirectRoute({
    required this.handler,
    required PathParser path,
    required List<String> methods,
    required List beforeMW,
    required List afterMW,
    required List accepted,
  }) : super(
          accepted: accepted,
          methods: methods,
          path: path,
          beforeMW: beforeMW,
          afterMW: afterMW,
        );

  bool match(HttpRequest req) {
    if (!methods.contains(req.method)) return false;
    return path.match(req.uri.path);
  }

  static parse({
    required DirectHandler handler,
    required String method,
    required String path,
    List beforeMW = const [],
    List afterMW = const [],
    List accepted = const [],
  }) {
    PathParser pathParser = PathParser.parse(path, endWith: true);

    List<String> methods = method
        .replaceAll(' ', '')
        .split(',')
        .map((e) => e.toUpperCase())
        .toList();

    return DirectRoute(
      handler: handler,
      path: pathParser,
      methods: methods,
      beforeMW: beforeMW,
      afterMW: afterMW,
      accepted: accepted,
    );
  }
}
