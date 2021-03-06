library cruky.handlers;

import 'dart:io';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/common/path_pattern.dart';
import 'package:cruky/src/errors/exp_res.dart';
import 'package:cruky/src/request/common/query.dart';
import 'package:cruky/src/handlers/middleware/main.dart';
import 'package:cruky/src/scanner/scanner.dart';
import 'package:meta/meta.dart';

abstract class RouteHandler {
  final List<Middleware> pre;
  final List<Middleware> post;
  final List<String> acceptedContentType;
  RouteHandler(PipelineMock mock, {this.acceptedContentType = const []})
      : pre = List.of(mock.pre, growable: false),
        post = List.of(mock.post, growable: false);

  Future handle(Request req);

  @nonVirtual
  Future call(
    HttpRequest req,
    PathPattern pattern,
  ) async {
    if (!acceptedContentType.contains(req.headers.contentType?.mimeType) &&
        acceptedContentType.isNotEmpty) {
      return ERes.e415();
    }

    Request reqCTX = Request(
      native: req,
      pattern: pattern,
      path: pattern.parseParams(req.uri.path),
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
