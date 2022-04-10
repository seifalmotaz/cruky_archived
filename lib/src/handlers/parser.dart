library cruky.handlers.parser;

import 'dart:mirrors';

import 'package:cruky/src/handlers/form.dart';
import 'package:cruky/src/handlers/iform.dart';
import 'package:cruky/src/handlers/json.dart';
import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/helpers/liberror.dart';
import 'package:cruky/src/helpers/path_parser.dart';
import 'package:cruky/src/interfaces/handler.dart';

import 'blank.dart';
import 'direct.dart';

final Map<Type?, HandlerType> _mainTypes = {
  directType: directHandler,
  jsonType: jsonHandler,
  formType: formHandler,
  iFormType: iFormHandler,
};

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
  final Map<Type?, HandlerType> types;
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

    var reflect2 = reflect(func) as ClosureMirror;
    List<Type> annoTypes = reflect2.function.metadata
        .where((e) => e.reflectee is HandlerInfo)
        .map((e) => e.reflectee.runtimeType)
        .toList();

    if (annoTypes.isNotEmpty) {
      var type = types[annoTypes.first];
      if (type == null) {
        var sourceLocation = reflect2.function.location!;
        throw LibError(
          'There is no handler type like $func',
          "${sourceLocation.sourceUri.toFilePath()}:${sourceLocation.line}:${sourceLocation.column}",
        );
      }
      return await type.parser(func, route);
    }

    for (var item in types.entries) {
      if (item.value.match(func, annoTypes)) {
        return await item.value.parser(func, route);
      }
    }

    throw 'Method of path $path has no handler type';
  }
}
