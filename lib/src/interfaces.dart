/// A class that have the required getters and
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

/// this class is like the [AppMatrial] class but instead of manual adding
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
  /// this is a list of used plugins in your app
  List<PluginApp> get plugins => [];

  /// choose server address
  String get address => '127.0.0.1';

  /// choose server port
  int get port => 5000;

  /// choose to run the app in debug mode or not
  bool get debug => true;

  /// this method will be called after calling init method
  /// and running http servers on every isolate
  // void ready() async {}

  /// this method will be called before
  /// closing all http servers on all isolates
  // void close() async {}

  /// this is a method that will call on every
  /// isolate to run the server with the returned data from __CrukyServer__
  void init() async {}
}

/// an app to add it to the main app as plugin
/// and it will be united with the main app
class PluginApp {
  /// this method will be called before calling init method and
  /// running http servers on every isolate
  void onInit() {}

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

  List get handlers => [];
}
