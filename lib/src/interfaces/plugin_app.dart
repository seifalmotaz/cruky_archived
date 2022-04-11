library cruky.plugin_app;

import 'package:cruky/src/handlers/parser.dart';

import 'app_material.dart';

abstract class PluginApp extends AppMaterial {
  /// types of handlers you can add custom type here
  List<HandlerType> get handlerTypes => [];

  /// this method called before the binding the http server.
  Future onlisten() async {}

  @override
  List get routes => [];
}
