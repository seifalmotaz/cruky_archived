library cruky.request;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cruky/src/params/path_parser.dart';
import 'package:mime/mime.dart';

import '../utils/utils.dart';

part './file_part.dart';
part './req_converter.dart';

class ReqCTX {
  final DateTime at = DateTime.now();

  /// http request headers
  final HttpRequest native;

  Uri get uri => native.uri;
  X509Certificate? get certificate => native.certificate;
  List<Cookie> get cookies => native.cookies;
  HttpSession get session => native.session;

  /// the request uri
  final Uri path;

  /// the request uri query
  final Map query;

  /// path parameters
  final Map parameters;

  /// middlewares returned data
  final Map<String, dynamic> extra = {};

  void add(String key, value) => extra.addAll({key: value});

  headerValue(String name) => native.headers.value(name);

  /// operator
  dynamic operator [](String i) =>
      extra[i] ?? query[i] ?? parameters[i] ?? native.headers.value(i);

  /// init
  ReqCTX({
    required this.native,
    required this.path,
    required this.parameters,
    required this.query,
  });
}
