import 'dart:convert';
import 'dart:io';

/// response context helper
class ResCTX {
  /// the native response class
  late HttpResponse httpResponse;

  ///  adding custom status to the response
  status(int i) => httpResponse.statusCode = i;

  /// add new headers to the response headers
  header(String i, Object value) => httpResponse.headers.set(i, value);

  /// response contentType
  ContentType? get contentType => httpResponse.headers.contentType;

  /// return json data
  void json(Object body) {
    httpResponse.headers.contentType = ContentType.json;
    httpResponse.write(jsonEncode(body));
  }
}
