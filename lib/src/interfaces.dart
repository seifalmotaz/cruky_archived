import 'dart:io';

/// HttpServer binding info
class ServerBind {
  /// server address
  final String address;

  /// server port
  final int port;

  /// number of HttpServer listeners
  final int listeners;

  /// SecurityContext if you want to secure the protcol with HttpServer.bindSecure
  final SecurityContext? securityContext;

  /// HttpServer binding info
  ServerBind({
    this.address = '127.0.0.1',
    this.port = 5000,
    this.listeners = 2,
    this.securityContext,
  });
}

/// An interface that have the required getters and
/// methods to define an app to add it to the main entry app
abstract class AppMaterial {
  /// route path prefix that will be added
  /// to all the children routes or middleware
  String get prefix => '/';

  /// Application routes tree
  List get routes => [];

  /// Application level middleware
  List get pipeline => [];
}

/// Like the [AppMatrial] interface but instead of manual adding
/// to the routes getter, cruky will get the methods that have Route annotation
/// inside the class and use it as route.
abstract class InApp {
  /// route path prefix that will be added
  /// to all the children routes or middleware
  String get prefix => '/';

  /// Application level middleware
  List get pipeline => [];
}

/// class defines the main things that needed for the main entry app
abstract class ServerApp extends AppMaterial {
  /// app unique name for multi apps server
  String get name => 'MyApp';

  /// this is a list of used plugins in your app
  List<PluginApp> get plugins => [];

  Map<String, String> get statics => {};

  @Deprecated('not used for now')
  Map get globals => {};

  /// a method that will call on every
  /// isolate to run the server with the returned data from __ServerBind__
  ServerBind init() => ServerBind(
        address: '127.0.0.1',
        port: 5000,
        listeners: 2,
      );
}

/// an app to add it to the main app as plugin
/// and it will be united with the main app
class PluginApp {
  /// this method will be called before calling init method and
  /// running http servers on every isolate
  Future<void> onInit() async {}

  /// this method will be called after calling init method and
  /// running http servers on every isolate
  // void onReady() {}

  /// this method will be called before
  /// closing all http servers on all isolates
  // void onClose() {}

  /// Plugin routes tree
  List get routes => [];

  /// plugin middleware that will added to application level middleware
  List get pipeline => [];

  @Deprecated('not used for now')
  List get handlers => [];
}
