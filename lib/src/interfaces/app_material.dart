library cruky.app_matrial;

/// App interface used to define the required params for the app
abstract class AppMaterial {
  /// route path prefix
  String get prefix => '/';

  /// the routes to add to the main routes tree
  List get routes;

  /// adding global middlewares for this app
  List get middlewares => [];
}
