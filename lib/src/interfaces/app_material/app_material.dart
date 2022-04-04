/// App interface used to define the required params for the app
abstract class AppMaterial {
  /// route path prefex
  String get prefix => '/';

  /// not userd getter
  List get accepted => [];

  /// the routes to add to the main routes tree
  List get routes;

  /// adding global middlewares  for this app
  List get middlewares => [];
}
