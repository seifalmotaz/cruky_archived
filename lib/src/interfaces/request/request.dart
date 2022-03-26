library cruky.request;

import 'package:cruky/cruky.dart';
import 'package:cruky/src/interfaces/request/enum.dart';

part './json.dart';
part './form.dart';

class SimpleReq {
  /// http request headers
  final HttpHeaders headers;

  /// the request uri
  final Uri path;

  /// the request uri query
  final Map query;

  /// path parameters
  final Map parameters;

  /// middlewares returned data
  final Map<String, dynamic> middlewares;

  void middleware(String key, value) => middlewares.addAll({key: value});

  /// init
  SimpleReq({
    required this.headers,
    required this.path,
    required this.parameters,
    required this.query,
    this.middlewares = const {},
  });

  /// operator
  dynamic operator [](String i) =>
      middlewares[i] ?? query[i] ?? parameters[i] ?? headers.value(i);

  Set call(String i) {
    dynamic data;
    FieldParser? parser;
    if (query[i] != null) {
      data = query[i];
      parser = FieldParser.query;
    }
    if (parameters[i] != null) {
      data = query[i];
      parser = FieldParser.parameters;
    }
    return {data, parser};
  }
}
