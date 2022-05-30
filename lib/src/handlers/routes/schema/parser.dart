import 'dart:mirrors';

import 'package:cruky/src/annotation/annotation.dart';
import 'package:cruky/src/constants.dart';
import 'package:cruky/src/errors/exp_res.dart';
import 'package:cruky/src/request/common/file_part.dart';
import 'package:cruky/src/request/form_data.dart';
import 'package:cruky/src/request/req.dart';
import 'package:cruky/src/scanner/scanner.dart';

import './handler.dart';

List getParamSchema(ParameterMirror parameter) {
  final List<InstanseParam> params = [];
  ClassMirror mirror = reflectClass(parameter.type.reflectedType);
  Schema schema =
      mirror.metadata.map((e) => e.reflectee).firstWhere((e) => e is Schema);
  MethodMirror method = getParseConstructor(mirror)!;
  for (var item in method.parameters) {
    params.add(InstanseParam(
      name: MirrorSystem.getName(item.simpleName),
      type: item.type.reflectedType,
      isNullable: item.isOptional,
      isNamed: item.isNamed,
    ));
  }

  return [
    SchemaType(
      params: params,
      bindingType: schema.bindingType,
      newInstanse: mirror.newInstance,
    ),
    schema.accepted
  ];
}

MethodMirror? getParseConstructor(ClassMirror mirror) {
  List<MethodMirror> constructors = mirror.declarations.values
      .whereType<MethodMirror>()
      .where((e) => e.isConstructor)
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
  if (params.length != 2) return false;
  var mirror = reflectClass(params.last.type.reflectedType);
  MethodMirror? parser = getParseConstructor(mirror);
  if (parser != null) return true;
  return false;
}

Future<SchemaHandler?> parse(ClosureMirror handler, PipelineMock pipeline,
    List<String> acceptedContentType) async {
  var param = handler.function.parameters.last;
  List schemaType = getParamSchema(param);
  schemaTypes.addAll({param.type.reflectedType: schemaType.first});
  return SchemaHandler(
    pipeline,
    handler: handler.reflectee,
    schema: schemaType.first,
    accepted: schemaType.last,
  );
}

class InstanseParam {
  final String name;
  final bool isNamed;
  final Type type;
  final bool isNullable;
  const InstanseParam({
    required this.name,
    required this.type,
    required this.isNamed,
    required this.isNullable,
  });

  bool isList() => type.toString().startsWith('List');
  bool isMap() => type.toString().startsWith('Map');
}

class SchemaType {
  final BindingType bindingType;
  final List<InstanseParam> params;
  final InstanceMirror Function(Symbol, List, [Map<Symbol, dynamic>])
      newInstanse;

  SchemaType({
    required this.params,
    required this.newInstanse,
    required this.bindingType,
  });

  Future<Object> get(Request req) async {
    if (bindingType == BindingType.json) {
      return await _json(req);
    }
    if (bindingType == BindingType.form) {
      return await _form(req);
    }
    if (bindingType == BindingType.iform) {
      return await _iform(req);
    }
    return req;
  }

  Future<dynamic> _iform(Request req) async {
    iFormData form = await req.iForm();
    final List arguments = [];
    final Map<Symbol, dynamic> parameters = {};
    for (var param in params) {
      late dynamic data;
      data = switchType(param, form);
      if (data == null) {
        switch (param.type) {
          case FilePart:
            data = form.getFile(param.name);
            break;
          case List<FilePart>:
            data = form.formFiles[param.name];
            break;
        }
        if (data == null && !param.isNullable) {
          throw ExceptionResponse(ExpRes.e422({
            "validator": "field.required",
            "msg": "field `${param.name}` is required"
          }));
        }
      }
      if (param.isNamed) {
        parameters.addAll({Symbol(param.name): data});
      } else {
        arguments.add(data);
      }
    }
    return newInstanse(Symbol('parse'), arguments, parameters).reflectee;
  }

  Future<dynamic> _form(Request req) async {
    FormData form = await req.form();
    final List arguments = [];
    final Map<Symbol, dynamic> parameters = {};
    for (var param in params) {
      late dynamic data;
      data = switchType(param, form);
      if (data == null && !param.isNullable) {
        throw ExceptionResponse(ExpRes.e422({
          "validator": "field.required",
          "msg": "field `${param.name}` is required"
        }));
      }
      if (param.isNamed) {
        parameters.addAll({Symbol(param.name): data});
      } else {
        arguments.add(data);
      }
    }
    return newInstanse(Symbol('parse'), arguments, parameters).reflectee;
  }

  switchType(InstanseParam param, FormData form) {
    dynamic data;
    switch (param.type) {
      case String:
        data = form.getString(param.name);
        break;
      case bool:
        data = form.getBool(param.name);
        break;
      case num:
        data = form.getNum(param.name);
        break;
      case double:
        data = form.getDouble(param.name);
        break;
      case int:
        data = form.getInt(param.name);
        break;
      case List<int>:
        data = form.listInt(param.name);
        break;
      case List<double>:
        data = form.listDouble(param.name);
        break;
      case List<bool>:
        data = form.listBool(param.name);
        break;
      case List<num>:
        data = form.listNum(param.name);
        break;
    }
    if (data == null) {
      throw ExceptionResponse(ExpRes.e422({
        "validator": "field.type_error",
        "msg": "field `${param.name}` is not subtype of ${param.type}"
      }));
    }
  }

  Future<dynamic> _json(Request req) async {
    Map body = await req.json();
    final List arguments = [];
    final Map<Symbol, dynamic> parameters = {};
    for (var param in params) {
      var data = body[param.name];
      if (data == null && !param.isNullable) {
        throw ExceptionResponse(ExpRes.e422({
          "validator": "field.required",
          "msg": "field `${param.name}` is required"
        }));
      }
      if (param.isNamed) {
        parameters.addAll({Symbol(param.name): data});
      } else {
        arguments.add(data);
      }
    }
    return newInstanse(Symbol('parse'), arguments, parameters).reflectee;
  }
}
