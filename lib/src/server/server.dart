library cruky.server;

import 'dart:io';

import 'package:cruky/cruky.dart';
import 'package:cruky/handlers.dart';
import 'package:cruky/src/response/response.dart';

part './handlers.dart';
part './constants.dart';

class CrukyServer {
  final List<BlankRoute> routes;

  CrukyServer(this.routes);

  /// Internal http server
  List<HttpServer> _servers = <HttpServer>[];

  /// get http servers list
  Iterable<HttpServer> get servers => List.unmodifiable(_servers);

  void serve({
    String address = '127.0.0.1',
    int port = 5000,
    int threads = 5,
  }) async {
    try {
      for (var i = 0; i < threads; i++) {
        final server = await HttpServer.bind(address, port, shared: true);
        server.listen(_handle);
        _servers.add(server);
      }
    } catch (e) {
      try {
        await close();
      } catch (e) {
        // ignore error
      }
      rethrow;
    }
  }

  BlankRoute? _matchReq(HttpRequest req) {
    Iterable<BlankRoute> matches = routes.where((e) => e.match(req));
    if (matches.isEmpty) return null;
    if (matches.length > 1) {
      for (var item in matches) {
        if (item.path.path.split('/').join() ==
            req.uri.path.split('/').join()) {
          return item;
        }
      }
    }
    return matches.first;
  }

  /// Closes the servers
  Future<void> close() async {
    dynamic err;
    for (HttpServer server in _servers) {
      try {
        await server.close(force: true);
      } catch (e) {
        err ??= e;
      }
    }
    if (err != null) {
      throw err;
    }
    _servers = [];
  }
}
