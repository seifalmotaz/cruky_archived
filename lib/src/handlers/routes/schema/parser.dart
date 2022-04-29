import 'dart:mirrors';

import 'package:cruky/src/handlers/routes/schema/handler.dart';
import 'package:cruky/src/scanner/scanner.dart';

MethodMirror? getParseConstructor(Type param) {
  List<MethodMirror> constructors = reflectClass(param)
      .declarations
      .values
      .whereType<MethodMirror>()
      .where((e) => e.isConstConstructor)
      .toList();
  for (var item in constructors) {
    var name = MirrorSystem.getName(item.simpleName);
    if (name.endsWith('parse')) {
      return item;
    }
  }
  return null;
}

bool check(
  ClosureMirror handler,
  PipelineMock pipeline,
  List<String> accepted,
) {
  List<ParameterMirror> params = handler.function.parameters;
  if (params.length != 1) return false;
  MethodMirror? parser = getParseConstructor(params.first.type.reflectedType);
  if (parser != null) return true;
  return false;
}

Future<SchemaHandler?> parse(ClosureMirror handler, PipelineMock pipeline,
    List<String> acceptedContentType) async {
  return null;
}
