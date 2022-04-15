library cruky.handlers.parser;

import 'dart:mirrors';

import 'package:cruky/src/handlers/form.dart';
import 'package:cruky/src/handlers/iform.dart';
import 'package:cruky/src/handlers/indirect/parser.dart';
import 'package:cruky/src/handlers/json.dart';
import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/helpers/liberror.dart';
import 'package:cruky/src/helpers/path_parser.dart';
import 'package:cruky/src/interfaces/handler.dart';

import 'blank.dart';
import 'direct.dart';

class HandlerType<T extends Function> {
  final Type? annotiationType;
  final bool isDynamic;
  final Future Function(Function handler, BlankRoute route) parser;

  HandlerType({
    this.isDynamic = false,
    this.annotiationType,
    required this.parser,
  });

  match(Function func) => func is T;
}

class MethodParser {
  final Map<Type, HandlerType> dTypes = {
    inDirectType: inDirectHandler,
  }; // [dTypes] for dynamic types

  final List<HandlerType> types = [
    directHandler,
    jsonHandler,
    formHandler,
    iFormHandler,
  ];

  MethodParser(List<HandlerType> t) {
    for (var item in t) {
      if (item.isDynamic) {
        dTypes.addAll({item.annotiationType!: item});
      } else {
        types.add(item);
      }
    }
  }

  Future<BlankRoute> parse(
    Function func, {
    required List<String> methods,
    required String path,
    List<MethodMW> beforeMW = const [],
    List<MethodMW> afterMW = const [],
    List<String> accepted = const [],
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
      var type = dTypes[annoTypes.first];
      if (type != null) {
        return await type.parser(func, route);
      }
      try {
        type = types.firstWhere((e) => e.annotiationType == annoTypes.first);
        return await type.parser(func, route);
      } on StateError {
        var sourceLocation = reflect2.function.location!;
        throw LibError(
          'There is no handler type like ${annoTypes.first}',
          "${sourceLocation.sourceUri.toFilePath()}:${sourceLocation.line}:${sourceLocation.column}",
        );
      }
    }

    for (var item in types) {
      if (item.match(func)) {
        return await item.parser(func, route);
      }
    }

    Object? error;
    for (var item in dTypes.entries) {
      if (item.value.match(func)) {
        BlankRoute? result;
        try {
          result = await item.value.parser(func, route);
        } catch (e) {
          error = e;
          continue;
        }
        if (result != null) return result;
      }
    }

    throw error ??
        LibError.stack(
          reflect2.function.location!,
          'Method of path $path has no handler type',
        );
  }
}
