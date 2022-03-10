library cruky.handlers;

import 'dart:convert';
import 'dart:io';

import 'dart:mirrors';

import 'package:cruky/src/constants/header.dart';

part './method.dart';

abstract class RequestHandler {
  dynamic handler({
    required HttpRequest req,
    required Map<String, dynamic> pathParams,
    required Map<String, dynamic> pathQuery,
    required ReqHeader contentType,
  });
}

class MethodParam {
  String name;
  Type type;
  bool isOptional;
  MethodParam({
    required this.name,
    required this.type,
    required this.isOptional,
  });
}
