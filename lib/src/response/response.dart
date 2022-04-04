import 'dart:io';

abstract class Response {
  late int status;
  final Map<String, String> headers = {};

  void writeResponse(HttpRequest req) {
    req.response.statusCode = status;
    for (MapEntry item in headers.entries) {
      req.response.headers.set(item.key, item.value);
    }
  }
}
