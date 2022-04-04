import 'dart:convert';
import 'dart:io';

import './response.dart';

class Json extends Response {
  final dynamic body;
  Json(this.body, [int? _status]) : assert(body is List || body is Map) {
    status = _status ?? 200;
  }

  @override
  void writeResponse(HttpRequest req) {
    super.writeResponse(req);
    req.response.headers.contentType = ContentType.json;
    req.response.write(jsonEncode(body));
  }
}

class Text extends Response {
  final String body;
  Text(this.body, [int? _status]) {
    status = _status ?? 200;
  }

  @override
  void writeResponse(HttpRequest req) {
    super.writeResponse(req);
    req.response.headers.contentType = ContentType.text;
    req.response.write(body);
  }
}

class Html extends Response {
  final String body;
  Html(this.body, [int? _status]) {
    status = _status ?? 200;
  }

  @override
  void writeResponse(HttpRequest req) {
    super.writeResponse(req);
    req.response.headers.contentType = ContentType.html;
    req.response.write(body);
  }
}
