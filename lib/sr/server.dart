library cruky.server;

import 'dart:async';
import 'dart:convert';
import "dart:io";

import 'dart:mirrors';
import 'dart:typed_data';

import 'package:mime/mime.dart';

import 'handlers/handlers.dart';
import 'helper/path_regex.dart';
import 'helper/print_req.dart';
import 'middleware.dart';
import 'router/annotiation.dart';
import 'router/routes.dart';

part './routes_list.dart';

Future<void> serve({String host = '127.0.0.1', int port = 5000}) async {
  Cruky server = Cruky(host, port);
  LibraryMirror mirror = currentMirrorSystem().isolate.rootLibrary;
  server.addLib(mirror);
  await server.serve();
}

class Cruky extends RoutesList {
  String host;
  int port;
  Cruky([this.host = '127.0.0.1', this.port = 5000]);

  late HttpServer _httpServer;

  RouteMatch? match(String path, String method) {
    List<RouteMatch> routes =
        _routes.where((e) => e.match(path, method)).toList();
    if (routes.isEmpty) return null;
    if (routes.length == 1) {
      return routes.first;
    } else {
      for (RouteMatch item in routes) {
        if (pathRegEx(path).regExp == item.path.regExp) return item;
      }
    }
    return null;
  }

  Future<void> serve({String? host_, int? port_}) async {
    _httpServer = await HttpServer.bind(
      host_ ?? host,
      port_ ?? port,
      shared: true,
    );
    // start server listen
    print('Server running on http://$host:$port');
    await for (HttpRequest req in _httpServer) {
      Future<Uint8List> getBytes() {
        return req
            .fold<BytesBuilder>(BytesBuilder(copy: false), (a, b) => a..add(b))
            .then((b) => b.takeBytes());
      }

      Stream<Uint8List> stream;

      var bytes = await getBytes();
      var ctrl = StreamController<Uint8List>()
        ..add(bytes)
        ..close();
      stream = ctrl.stream;

      var parts = MimeMultipartTransformer(
              req.headers.contentType!.parameters['boundary']!)
          .bind(stream);

      await for (var part in parts) {
        // print(part);
        String h = part.headers['content-disposition']!;
        RegExpMatch filename = RegExp('filename="(.+)"').firstMatch(h)!;
        var s = part.map((event) => event);
        var f = await File(filename.group(1)!).create();
        await for (var item in s) {
          f.writeAsBytes(item);
        }
      }

      // String filename = RegExp('filename="(.+)"').firstMatch(h)!.group(0)!;
//         List filenameList = filename.split(RegExp('=|"'));
//         filenameList.removeWhere((e) => e.isEmpty);
      // File('./a.jpg').create().then((value) => value.writeAsBytes(stream));
      // get the request handler
      RouteMatch? route = match(req.uri.path, req.method);
      if (route == null) {
        req.response.statusCode = 404;
      } else {
        dynamic res = await route.handle(req);
        req.response.headers.contentType = ContentType.json;
        if (res is Map) {
          req.response.statusCode = res[#status] ?? 200;
          res.removeWhere((key, value) => key is Symbol);
          req.response.write(jsonEncode(res));
        } else {
          req.response.write(jsonEncode(res));
        }
      }
      // close and print response and goto next request
      req.response.close();
      printReq(req);
    }
  }

  void passLib({Symbol? symbol, Uri? uri}) {
    if (symbol != null) addLib(currentMirrorSystem().findLibrary(symbol));
    if (uri != null) addLib(currentMirrorSystem().libraries[uri]!);
  }

  void addLib(LibraryMirror lib) {
    List<DeclarationMirror> declarations = lib.declarations.values.toList();
    for (var declaration in declarations) {
      if (declaration.metadata
          .where((value) => value.reflectee is Route)
          .isEmpty) continue;
      if (declaration is MethodMirror) _addMethod(declaration);
      // if (declaration is ClassMirror) _addClass(declaration);
    }
  }
}
