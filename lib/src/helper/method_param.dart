import 'dart:mirrors';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/helper/data_parser.dart';

class InParam {
  late final String name;
  late final Type type;
  late final bool isOptional;
}

class ParserParam extends InParam {
  late final InstanceMirror Function(
    Symbol constructorName,
    List<dynamic> positionalArguments, [
    Map<Symbol, dynamic> namedArguments,
  ]) newInstance;
  final List<InParam> params = [];

  DataParser parseBody(SimpleReq request) {
    final Map<Symbol, dynamic> paramMap = {};
    for (InParam item in params) {
      final data = request[item.name];
      if (data == null && !item.isOptional) {
        return DataParser(null, {
          #status: 400,
          "msg": "missing field ${item.name}",
        });
      }
      if (data != null) {
        if (request is JsonReq && request[item.name] != null) {
          paramMap[Symbol(item.name)] = data;
          continue;
        }
        paramMap[Symbol(item.name)] = checkType(data, item.type);
      }
    }
    return DataParser(paramMap, null);
  }
}

class MethodParams {
  Type? _requestContentType;
  final List<InParam> list = [];

  Type get requestContentType => _requestContentType ?? JsonReq;

  bool isRegularType(Type type) =>
      type == String ||
      type == int ||
      type == double ||
      type == Map ||
      type == List;

  void add(ParameterMirror param) {
    if (isRegularType(param.type.reflectedType)) {
      InParam _param = InParam();
      _param.name = MirrorSystem.getName(param.simpleName);
      _param.type = param.type.reflectedType;
      _param.isOptional = param.isOptional;
      list.add(_param);
      return;
    } else if (param.type.reflectedType == FilePart) {
      _requestContentType = iFormReq;
      InParam _param = InParam();
      _param.name = MirrorSystem.getName(param.simpleName);
      _param.type = param.type.reflectedType;
      _param.isOptional = param.isOptional;
      list.add(_param);
      return;
    }

    ClassMirror classMirror = reflectClass(param.type.reflectedType);

    ParserParam parserParam = ParserParam();
    parserParam.name = MirrorSystem.getName(param.simpleName);
    parserParam.type = param.type.reflectedType;
    parserParam.isOptional = param.isOptional;
    parserParam.newInstance = classMirror.newInstance;

    var constructor = classMirror.declarations[classMirror.simpleName];
    if (constructor == null) {
      throw ArgumentError('The model parser ${classMirror.simpleName}'
          ' does not have a constructor method');
    }
    constructor as MethodMirror;

    for (ParameterMirror _param in constructor.parameters) {
      InParam inParam = InParam();
      inParam.name = MirrorSystem.getName(_param.simpleName);
      inParam.type = _param.type.reflectedType;
      inParam.isOptional = _param.isOptional;
      parserParam.params.add(inParam);
    }

    list.add(parserParam);
  }
}
