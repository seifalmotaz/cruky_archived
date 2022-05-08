library cruky.server;

import 'dart:async';
import 'dart:io';

import 'package:cruky/src/errors/exp_res.dart';
import 'package:cruky/src/interfaces.dart';

import 'path_handler.dart';

class CrukyServer {
  final List<PathHandler> routes;

  CrukyServer(this.routes);

  /// Internal http server
  List<HttpServer> _servers = <HttpServer>[];

  /// get http servers list
  Iterable<HttpServer> get servers => List.unmodifiable(_servers);

  void serve(ServerBind app) async {
    try {
      for (var i = 0; i < app.listeners; i++) {
        final HttpServer server;
        if (app.securityContext != null) {
          server = await HttpServer.bindSecure(
            app.address,
            app.port,
            app.securityContext!,
            shared: true,
          );
        } else {
          server = await HttpServer.bind(app.address, app.port, shared: true);
        }
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
        ERes.e404().write(request);
      }
    } catch (e, s) {
      ERes.e500().write(request);
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
