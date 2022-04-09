library cruky.handlers.parser;

import 'dart:mirrors';

import 'package:cruky/src/handlers/json.dart';
import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/helpers/path_parser.dart';

import 'blank.dart';
import 'direct.dart';

final List<HandlerType> _mainTypes = [directHandler, jsonHandler];

class HandlerType<T> {
  final Type? annotiationType;
  final Future<BlankRoute> Function(Function handler, BlankRoute route) parser;

  HandlerType({
    this.annotiationType,
    required this.parser,
  });

  match(Function func, List<Type> anno) =>
      func is T || (annotiationType != null && anno.contains(annotiationType));
}

class MethodParser {
  final List<HandlerType> types;
  MethodParser(this.types) {
    types.addAll(_mainTypes);
  }

  Future<BlankRoute> parse(
    Function func, {
    required List<String> methods,
    required String path,
    List<MethodMW> beforeMW = const [],
    List<MethodMW> afterMW = const [],
    List accepted = const [],
  }) async {
    BlankRoute route = BlankRoute(
      path: PathParser.parse(path, endWith: true),
      methods: methods,
      accepted: accepted,
      beforeMW: beforeMW,
      afterMW: afterMW,
    );

    List<Type> annoTypes = (reflect(func) as ClosureMirror)
        .function
        .metadata
        .map((e) => e.reflectee.runtimeType)
        .toList();

    for (var item in types) {
      if (item.match(func, annoTypes)) {
        return await item.parser(func, route);
      }
    }

    throw 'Method of path $path has no handler type';
  }
}
