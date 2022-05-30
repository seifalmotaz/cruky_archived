library cruky.server;

import 'dart:async';
import 'dart:io';

import 'package:cruky/src/errors/exp_res.dart';
import 'package:cruky/src/gen/gen.dart';
import 'package:cruky/src/interfaces.dart';

import '../path/handler.dart';

class CrukyServer {
  final SecurityContext? securityContext;
  final List<PathHandler> routes;

  CrukyServer(this.routes, [this.securityContext]) {
    genOpenApi(routes);
  }

  /// Internal http server
  List<HttpServer> _servers = <HttpServer>[];

  /// get http servers list
  List<HttpServer> get servers => List.unmodifiable(_servers);

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
    List<PathHandler> matches =
        routes.where((e) => e.match(req.uri.path)).toList();
    if (matches.isEmpty) return null;
    if (matches.length == 1) return matches.first;
    // Map<int, int> scores = {};

    // for (var i = 0; i < matches.length; i++) {
    //   PathPattern matchPath = matches[i].pattern;
    //   for (var p = 0; p < path.length; p++) {
    //     bool b = matchPath.matchSeg(path[p], p);
    //     if (b) scores[i] = (scores[i] ?? 0) + 1;
    //   }
    // }

    // int i = 0;
    // int iScore = 0;

    // scores.forEach((key, value) {
    //   if (value > iScore) {
    //     iScore = value;
    //     i = key;
    //   }
    // });

    // return matches[i];
    return null;
  }

  void _handle(HttpRequest request) {
    try {
      PathHandler? matched = _matchReq(request);
      if (matched != null) {
        matched(request);
      } else {
        ExpRes.e404().write(request);
      }
    } catch (e, s) {
      ExpRes.e500().write(request);
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
