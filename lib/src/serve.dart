import 'dart:mirrors';

import 'package:cruky/cruky.dart';
import 'package:watcher/watcher.dart';

/// serve the app with hotreload option
/// hotreloader defaults watch the lib folder
void serveWithHotReload() => HotReload(serve)..run();

/// serve the app
Future<Cruky> serve({String host = '127.0.0.1', int port = 5000}) async {
  Cruky server = Cruky(host, port);
  LibraryMirror mirror = currentMirrorSystem().isolate.rootLibrary;
  server.addLib(mirror);
  await server.bind(host_: host, port_: port);
  server.serve();
  return server;
}

/// hotreload helper
class HotReload {
  Cruky? server;
  bool inProcess = false;
  Future<Cruky> Function() function;
  HotReload(this.function);

  /// run the server app
  Future<void> run() async {
    server = await function();
    if (!server!.isListening) server!.serve();
    DirectoryWatcher('./lib', pollingDelay: Duration(seconds: 5))
        .events
        .listen((event) async {
      if (inProcess) return;
      print('Restarting');
      inProcess = true;
      await server?.close();
      server = null;
      server = await function();
      if (!server!.isListening) server!.serve();
      inProcess = false;
    });
  }
}
