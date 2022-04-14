library cruky.handlers.in_direct;

import 'dart:mirrors';

import 'package:cruky/cruky.dart';
import 'package:cruky/handlers.dart';
import 'package:cruky/src/common/ansicolor.dart';
import 'package:cruky/src/common/enum.dart';
import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/handlers/indirect/data_converter.dart';
import 'package:cruky/src/helpers/liberror.dart';
import 'package:cruky/src/helpers/path_parser.dart';
import 'package:cruky/src/interfaces/handler.dart';

part './in_query.dart';
part './in_json.dart';

final inDirectHandler = HandlerType<Function>(
  parser: inDirectParse,
  annotiationType: inDirectType,
  isDynamic: true,
);

/// direct route annotiation
const inDirect = _InDirect();
const Type inDirectType = _InDirect;

/// direct route annotiation
class _InDirect extends HandlerInfo {
  /// direct route annotiation
  const _InDirect();
}

/// protypes function
typedef ApplyMethod = InstanceMirror Function(List<dynamic> positionalArguments,
    [Map<Symbol, dynamic> namedArguments]);

class SchemaParam {
  final TypeMirror type;
  final String name;
  final Symbol symbol;
  final bool isOptional;
  final BindFrom bindFrom;

  SchemaParam({
    required this.name,
    required this.symbol,
    required this.type,
    required this.isOptional,
    required this.bindFrom,
  });
}

Future<BlankRoute?> inDirectParse(Function handler, BlankRoute route) async {
  List<SchemaParam> schema = [];
  // int queryArgs = 0;
  int jsonArgs = 0;
  ClosureMirror mirror = reflect(handler) as ClosureMirror;
  for (var element in mirror.function.parameters) {
    bool i = getIfQuery(element, schema, route);
    if (i) {
      // queryArgs++;
      continue;
    }
    i = getIfJson(element, schema, route);
    if (i) {
      jsonArgs++;
      continue;
    }
  }
  if (jsonArgs > 0) {
    return InJsonRoute(
      handler: mirror.apply,
      schema: schema,
      path: route.path,
      methods: route.methods,
      beforeMW: route.beforeMW,
      afterMW: route.afterMW,
      accepted: [MimeTypes.json],
    );
  }
  return InQueryRoute(
    handler: mirror.apply,
    schema: schema,
    path: route.path,
    methods: route.methods,
    beforeMW: route.beforeMW,
    afterMW: route.afterMW,
    accepted: [],
  );
}

bool getIfQuery(
  ParameterMirror element,
  List<SchemaParam> schema,
  BlankRoute route,
) {
  final bool isLangType = _queryValidType(element.type);
  if (isLangType && element.metadata.isEmpty) {
    schema.add(SchemaParam(
      name: MirrorSystem.getName(element.simpleName),
      symbol: element.simpleName,
      type: element.type,
      isOptional: element.isOptional,
      bindFrom: BindFrom.query,
    ));
    return true;
  }
  for (var item in element.metadata) {
    if (item.reflectee is _QueryBind) {
      if (isLangType) {
        schema.add(SchemaParam(
          name: MirrorSystem.getName(element.simpleName),
          symbol: element.simpleName,
          type: item.type,
          isOptional: element.isOptional,
          bindFrom: BindFrom.query,
        ));
        return true;
      } else {
        throw LibError.stack(
          element.location!,
          '${danger("InDirect (${route.path}):")} the argument that binded '
          'from request query cannot be ${element.type.reflectedType}',
        );
      }
    }
  }
  return false;
}

bool getIfJson(
  ParameterMirror element,
  List<SchemaParam> schema,
  BlankRoute route,
) {
  final bool isLangType = _jsonValidType(element.type);
  if (isLangType && element.metadata.isEmpty) {
    schema.add(SchemaParam(
      name: MirrorSystem.getName(element.simpleName),
      symbol: element.simpleName,
      type: element.type,
      isOptional: element.isOptional,
      bindFrom: BindFrom.json,
    ));
    return true;
  }
  for (var item in element.metadata) {
    if (item.reflectee is _JsonBind) {
      if (isLangType) {
        schema.add(SchemaParam(
          name: MirrorSystem.getName(element.simpleName),
          symbol: element.simpleName,
          type: item.type,
          isOptional: element.isOptional,
          bindFrom: BindFrom.json,
        ));
        return true;
      } else {
        throw LibError.stack(
          element.location!,
          '${danger("InDirect (${route.path}):")} the argument that binded '
          'from request json body cannot be ${element.type.reflectedType}',
        );
      }
    }
  }
  return false;
}
