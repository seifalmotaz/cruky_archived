import 'dart:mirrors';

import 'package:cruky/cruky.dart';

class InParam {
  late String name;
  late Type type;
  late bool isOptional;
}

class MethodParams {
  Type? _requestContentType;
  final List<InParam> list = [];

  Type get requestContentType => _requestContentType ?? JsonRequest;

  bool isRegularType(Type type) =>
      type == String ||
      type == int ||
      type == double ||
      type == Map ||
      type == List;

  void add(ParameterMirror param) {
    InParam _param = InParam();
    if (isRegularType(param.type.reflectedType)) {
      _param.name = MirrorSystem.getName(param.simpleName);
      _param.type = param.type.reflectedType;
      _param.isOptional = param.isOptional;
      list.add(_param);
      return;
    } else if (param.type.reflectedType == FilePart) {
      _requestContentType = iFormRequest;
      InParam _param = InParam();
      _param.name = MirrorSystem.getName(param.simpleName);
      _param.type = param.type.reflectedType;
      _param.isOptional = param.isOptional;
      list.add(_param);
      return;
    }
  }
}
