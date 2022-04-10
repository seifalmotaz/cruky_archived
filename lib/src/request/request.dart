library cruky.request;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart';

import '../utils/utils.dart';

part './file_part.dart';
part './req_converter.dart';

/// the data that passed from middleware to the main method os other middlewares
class PassedData {
  final Map passedData = {};

  operator [](Object i) => passedData[i];
  operator []=(Object i, Object value) => passedData.addAll({i: value});
}

/// the basic request ctx helper to get the request content easily
class ReqCTX {
  final DateTime at = DateTime.now();

  /// http request headers
  final HttpRequest native;

  /// http response
  HttpResponse get response => native.response;

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

  String? headerValue(String name) => native.headers.value(name);

  /// operator
  dynamic operator [](String i) =>
      query[i] ?? parameters[i] ?? native.headers.value(i);

  /// the request uri query
  final PassedData data = PassedData();

  /// init
  ReqCTX({
    required this.native,
    required this.path,
    required this.parameters,
    required this.query,
  });
}
