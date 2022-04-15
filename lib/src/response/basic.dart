import 'dart:convert';
import 'dart:io';

import './response.dart';

/// Json response
class Json extends Response {
  final dynamic body;
  Json(this.body, [int? _status]) : assert(body is List || body is Map) {
    statusCode = _status ?? 200;
  }

  @override
  Future writeResponse(HttpRequest req) async {
    super.writeResponse(req);
    req.response.headers.contentType = ContentType.json;
    req.response.write(jsonEncode(body));
  }
}

/// Text plain response
class Text extends Response {
  final String body;
  Text(this.body, [int? _status]) {
    statusCode = _status ?? 200;
  }

  @override
  Future writeResponse(HttpRequest req) async {
    super.writeResponse(req);
    req.response.headers.contentType = ContentType.text;
    req.response.write(body);
  }
}

/// Html response
class Html extends Response {
  final String fileName;
  final Map? data;
  Html(this.fileName, {int? status, this.data}) {
    statusCode = status ?? 200;
  }

  @override
  Future writeResponse(HttpRequest req) async {
    super.writeResponse(req);
    req.response.headers.contentType = ContentType.html;
    req.response.write(await File(fileName).readAsString());
  }
}

/// Html response
class Redirect extends Response {
  final Uri uri;
  Redirect(url, [int? status]) : uri = Uri.parse(url) {
    statusCode = status ?? 200;
  }

  Redirect.uri(this.uri, [int? status]) {
    statusCode = status ?? 200;
  }

  @override
  Future writeResponse(HttpRequest req) async {
    super.writeResponse(req);
    req.response.redirect(uri);
  }
}