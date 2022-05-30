library cruky.handlers;

import 'dart:io';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/path/pattern.dart';
import 'package:cruky/src/request/common/query.dart';
import 'package:cruky/src/handlers/middleware/main.dart';
import 'package:cruky/src/scanner/scanner.dart';
import 'package:meta/meta.dart';

abstract class RouteHandler {
  final List<Middleware> pre;
  final List<Middleware> post;
  final List<String> acceptedContentType;
  RouteHandler(PipelineMock mock, this.acceptedContentType)
      : pre = List.of(mock.pre, growable: false),
        post = List.of(mock.post, growable: false);

  Future handle(Request req);
  Future<Map?> openapi(List<ParameterInfo> params) async {
    Map doc = {
      "parameters": [],
      "description": "",
      "responses": {},
    };
    for (var param in params) {
      Map data = {
        "required": true,
        "name": param.name,
        "in": "path",
        "schema": {"title": param.name}
      };
      switch (param.type) {
        case int:
          data['schema']!['type'] = 'integer';
          break;
        case double:
          data['schema']!['type'] = 'number';
          data['schema']!['format'] = 'double';
          break;
        case num:
          data['schema']!['type'] = 'number';
          break;
        default:
          data['schema']!['type'] = 'string';
      }
      doc['parameters']!.add(data);
    }
    return doc;
  }

  @nonVirtual
  Future call(
    HttpRequest req,
    PathPattern pattern,
  ) async {
    if (!acceptedContentType.contains(req.headers.contentType?.mimeType) &&
        acceptedContentType.isNotEmpty) {
      return ExpRes.e415();
    }

    Request reqCTX = Request(
      native: req,
      path: pattern.parse(req.uri.path),
      query: QueryParameters(req.uri),
    );

    for (var item in pre) {
      final _result = await item.handle(reqCTX);
      if (_result != null) {
        return _result;
      }
    }

    final result = await handle(reqCTX);

    for (var item in post) {
      final _result = await item.handle(reqCTX);
      if (_result != null) {
        return _result;
      }
    }
    return result;
  }
}
