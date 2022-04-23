library cruky.server_app;

import 'package:cruky/handlers.dart';
import 'package:cruky/src/interfaces/app_material.dart';
import 'package:cruky/src/interfaces/plugin_app.dart';

/// This is the main entry point for the server.
///
/// Here we define the settings of server like (address, port, isolates, cores)
///
/// it's abstract of AppMatrial but with extra options
abstract class ServerApp extends AppMaterial {
  /// the server listen address
  String get address => '127.0.0.1';

  /// server port
  int get port => 5000;

  /// number of server listeners in the single isolate
  int get cores => 5;

  /// number of isolate that will run the app
  int get isolates => 1;

  /// types of handlers you can add custom type here
  List<HandlerType> get handlerTypes => [];

  /// this is a list of used plugins in your app
  List<PluginApp> get plugins => [];
  Future onlisten() async {}
}
