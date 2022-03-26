library cruky.server;

import 'dart:convert';
import 'dart:io';

import 'dart:mirrors';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/constants.dart';
import 'package:logging/logging.dart';

import '../handler/handlers.dart';
import '../helper/method_param.dart';
import '../helper/path_regex.dart';
import '../helper/print_req.dart';

part 'prebinding.dart';

/// init the  server app with cruky
///
/// ```dart
/// Cruky app = Cruky();
/// or
/// Cruky app = Cruky(customHost, customPort);
///
/// // adding the HttpServer.bind()
/// await app.bind();
/// // start server
/// app.serve();
/// ```
class Cruky {
  String host;
  int port;
  Cruky([this.host = '127.0.0.1', this.port = 5000]);

  late HttpServer httpServer;
  final List<MethodHandler> routes = [];

  MethodHandler? _match(String path, String method) {
    List<MethodHandler> _routes =
        routes.where((e) => e.match(path, method)).toList();
    if (_routes.isEmpty) return null;
    if (_routes.length == 1) {
      return _routes.first;
    } else {
      for (MethodHandler item in routes) {
        if (pathRegEx(path).regExp == item.path.regExp) return item;
      }
    }
    return null;
  }

  Future<void> close() async {
    await httpServer.close(force: true);
    print('Server closed');
  }

  /// binding HttpServer and start logger listening
  bind({String? host_, int? port_}) async {
    httpServer = await HttpServer.bind(
      host_ ?? host,
      port_ ?? port,
      shared: true,
    );
    Logger.root.level = Level.ALL;
    await Directory('./log').create();
    File fileLogging = File('./log/main.log');
    IOSink sink = fileLogging.openWrite();
    if (!(await fileLogging.exists())) await fileLogging.create();
    Logger.root.onRecord.listen((record) {
      late String string = '';
      if (record.level == Level.INFO) {
        string = '\x1B[34m${record.level.name}\x1B[0m: ${record.message}';
      } else if (record.level == Level.WARNING) {
        string = '\x1B[33m${record.level.name}\x1B[0m: ${record.message}';
      } else if (record.level == Level.SHOUT) {
        string = '\x1B[31m${record.level.name}\x1B[0m: ${record.message}';
      } else if (record.level == Level.FINE) {
        string = '\x1B[36m${record.level.name}\x1B[0m: ${record.message}';
      } else if (record.level == Level.CONFIG) {
        string = '\x1B[37m${record.level.name}\x1B[0m: ${record.message}';
      }
      print(string);
      sink.writeln(string);
    });
  }

  /// start server listening
  Future<void> serve() async {
    /// start server listen
    crukyLogger.info('Server running on http://$host:$port');

    /// async listen
    await for (HttpRequest req in httpServer) {
      ResCTX resCTX = ResCTX();
      resCTX.httpResponse = req.response;
      try {
        MethodHandler? route = _match(req.uri.path, req.method);
        if (route == null) {
          resCTX.status(404);
        } else {
          await route.handle(req, resCTX);
        }
      } catch (e) {
        resCTX.status(500);
        if (e is Map) {
          resCTX.json(e);
        } else {
          resCTX.json({
            "Unhandled error": e.toString(),
          });
        }
      }

      /// close and print response and goto next request
      req.response.close();
      printReq(req);
    }
  }
}
