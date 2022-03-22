import 'dart:mirrors';

import 'package:cruky/cruky.dart';

/// serve the app
Future<Cruky> serve({String host = '127.0.0.1', int port = 5000}) async {
  Cruky server = Cruky(host, port);
  LibraryMirror mirror = currentMirrorSystem().isolate.rootLibrary;
  server.passLib(mirror.simpleName);
  await server.bind(host_: host, port_: port);
  server.serve();
  return server;
}
