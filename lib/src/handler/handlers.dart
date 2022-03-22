library cruky.handlers;

import 'dart:async';
import 'dart:io';
import 'dart:mirrors';

import 'package:cruky/src/handler/helpers/body_compiler.dart';
import 'package:cruky/src/helper/method_param.dart';
import 'package:cruky/src/helper/path_regex.dart';
import 'package:cruky/src/interfaces/request/request.dart';

part 'direct.dart';
part 'indirect.dart';

abstract class MethodHandler {
  final String method;
  final PathRegex path;
  final Type requestType;
  MethodHandler({
    required this.path,
    required this.method,
    required this.requestType,
  });

  Future handle(HttpRequest request);

  bool match(String _path, String _method) {
    if (_method != method) return false;
    return path.match(_path);
  }
}
