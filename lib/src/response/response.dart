import 'dart:io';

abstract class Response {
  late int statusCode;
  final Map<String, String> headers = {};

  Future writeResponse(HttpRequest req) async {
    req.response.statusCode = statusCode;
    for (MapEntry item in headers.entries) {
      req.response.headers.set(item.key, item.value);
    }
  }
}
