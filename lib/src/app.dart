import 'dart:async';

import 'package:cruky/cruky.dart';

import 'interfaces.dart';

class ServerApp {
  ServerApp([this.prefix = '/']);

  String name = 'MyApp';
  final List<PluginApp> plugins = [];
  final Map<String, String> statics = {};

  final String prefix;
  final List routes = [];
  final List pipeline = [];

  @Deprecated('not used for now')
  final Map globals = {};
  FutureOr<void> Function()? init;

  /// new route function or [AppMaterial]
  route(i) => routes.add(i);

  /// add a function that runs when the server ready in the isolate
  on(FutureOr<void> Function() i) => init = i;

  /// to add a pipeline/middlware or [PluginApp]
  use(i) => i.runtimeType == PluginApp ? plugins.add(i) : pipeline.add(i);

  /// To expose a current dir throw the [exposeRoute]
  ///
  /// the dir must be written as the command line working directory.
  ///
  /// so If you run the command `dart run` in directory called './mydirectery'
  /// then to expose the static folder you must write './static'.
  ///
  /// If you run the command `dart run` in directory called './mydirectery/nested'
  /// then to expose the static folder you must write '../static'.
  static(String dir, String exposeRoute) => statics.addAll({dir: exposeRoute});

  void run() {}
}
