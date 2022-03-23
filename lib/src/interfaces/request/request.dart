library cruky.request;

import 'package:cruky/src/interfaces/file_part.dart';
import 'package:cruky/src/interfaces/request/enum.dart';

part './json.dart';
part './form.dart';

class SimpleRequest {
  /// the request uri
  final Uri path;

  /// the request uri query
  final Map query;

  /// path parameters
  final Map parameters;

  /// init
  SimpleRequest({
    required this.path,
    required this.parameters,
    required this.query,
  });

  /// operator
  dynamic operator [](String i) => query[i] ?? parameters[i];

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
