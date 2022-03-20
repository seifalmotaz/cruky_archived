library cruky.handlers;

import 'dart:convert';
import 'dart:io';

import 'dart:mirrors';

import 'package:cruky/sr/constants/header.dart';
import 'package:cruky/sr/interfaces/request/request.dart';
import 'package:cruky/sr/middleware.dart';

part './method.dart';
part './fast.dart';

abstract class RequestHandler {
  List<MiddlewareMap> middlewares;
  RequestHandler(this.middlewares);
  dynamic handler({
    required HttpRequest req,
    required Map<String, dynamic> pathParams,
    required Map<String, dynamic> pathQuery,
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
