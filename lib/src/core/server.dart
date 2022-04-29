library cruky.server;

import 'dart:async';
import 'dart:io';

import 'package:cruky/src/core/res.dart';

import 'path_handler.dart';

class CrukyServer {
  final List<PathHandler> routes;

  CrukyServer(this.routes);

  /// Internal http server
  List<HttpServer> _servers = <HttpServer>[];

  /// get http servers list
  Iterable<HttpServer> get servers => List.unmodifiable(_servers);

  void serve(
    String address,
    int port,
    int listeners,
  ) async {
    try {
      for (var i = 0; i < listeners; i++) {
        final server = await HttpServer.bind(address, port, shared: true);
        runZonedGuarded(() {
          server.listen(_handle);
        }, (e, s) {
          try {
            close();
          } catch (e) {
            // ignore error
          }
          print(e);
          print(s);
        });
        _servers.add(server);
      }
    } catch (e) {
      try {
        close();
      } catch (e) {
        // ignore error
      }
      rethrow;
    }
  }

  PathHandler? _matchReq(HttpRequest req) {
    var path2 = req.uri.path;
    Iterable<PathHandler> matches = routes.where((e) => e.match(path2));
    if (matches.isEmpty) return null;
    if (matches.length > 1) {
      for (var item in matches) {
        if (item.path.split('/').join() == path2.split('/').join()) {
          return item;
        }
      }
    }
    return matches.first;
  }

  void _handle(HttpRequest request) {
    try {
      PathHandler? matched = _matchReq(request);
      if (matched != null) {
        matched(request);
      } else {
        Text('Not found', 404).write(request);
      }
    } catch (e, s) {
      Text('Server error', 500).write(request);
      print(e);
      print(s);
    }
  }

  /// Closes the servers
  void close() {
    dynamic err;
    for (HttpServer server in _servers) {
      try {
        server.close(force: true);
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
