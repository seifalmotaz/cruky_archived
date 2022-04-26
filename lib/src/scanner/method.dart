import 'dart:mirrors';
import 'package:cruky/src/annotation.dart';
import 'package:cruky/src/common/string_converter.dart';
import 'package:cruky/src/errors/liberrors.dart';
import 'package:cruky/src/handlers/routes/abstract.dart';
import 'package:cruky/src/handlers/routes/app/text.dart';
import 'package:cruky/src/handlers/routes/direct.dart';
import 'package:cruky/src/handlers/routes/app/json.dart';
import 'package:cruky/src/scanner/scanner.dart';

typedef ParserFunction<T> = T Function(
  ClosureMirror,
  PipelineMock,
  List<String>,
);

class HandlerType {
  final ParserFunction<Future> parser;
  final ParserFunction<bool> checker;
  HandlerType(this.parser, this.checker);
}

class RouteMock {
  final List<String> methods;
  final String path;
  final RouteHandler handler;
  RouteMock({
    required this.path,
    required this.methods,
    required this.handler,
  });
}

class MethodParser {
  final List<RouteMock> list = [];
  final List<HandlerType> types = [
    HandlerType(
      DirectHandler.parse,
      DirectHandler.check,
    ),
    HandlerType(
      JsonHandler.parse,
      JsonHandler.check,
    ),
    HandlerType(
      TextHandler.parse,
      TextHandler.check,
    ),
  ];

  MethodParser(List<HandlerType> t) {
    types.addAll(t);
  }

  Future<void> parse(
    Function function,
    List<String> pathSeg,
    PipelineMock pipeline,
  ) async {
    var mirror = reflect(function) as ClosureMirror;
    pathSeg.removeWhere((e) => e.isEmpty);
    Iterable<Route> routes = mirror.function.metadata
        .where((e) => e.reflectee is Route)
        .map((e) => e.reflectee);

    for (var route in routes) {
      List<String> methods = route.methods.toUpperCase().split(',');
      methods.removeWhere((e) => e.isEmpty);
      PipelineMock line = await getPipelineMock(route.pipeline);
      pipeline.pre.addAll(line.pre);
      pipeline.post.addAll(line.post);
      RouteHandler? result;
      for (var type in types) {
        if (type.checker(mirror, pipeline, route.accepted)) {
          result = await type.parser(mirror, pipeline, route.accepted);
          if (result == null) continue;
          break;
        }
      }
      if (result == null) {
        throw LibError.stack(mirror.function.location!,
            'The function "${function.runtimeType}" does not have a handler type');
      }
      list.add(RouteMock(
        path: (pathSeg + route.path.getUrlSegmants()).join('/'),
        methods: methods,
        handler: result,
      ));
    }
  }
}
