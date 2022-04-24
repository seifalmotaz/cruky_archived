import 'dart:convert';
import 'dart:io';

abstract class Response {
  const Response();
  Future<void> write(HttpRequest req);
}

class Text extends Response {
  final String text;
  final int status;
  const Text(this.text, [this.status = 200]);

  @override
  Future<void> write(HttpRequest req) async {
    req.response.statusCode = status;
    req.response.headers.contentType = ContentType.text;
    req.response.write(text);
  }
}

class Json extends Response {
  final Object body;
  final int status;
  const Json(this.body, [this.status = 200])
      : assert(body is Map || body is List);

  @override
  Future<void> write(HttpRequest req) async {
    req.response.statusCode = status;
    req.response.headers.contentType = ContentType.json;
    req.response.write(jsonEncode(body));
  }
}
