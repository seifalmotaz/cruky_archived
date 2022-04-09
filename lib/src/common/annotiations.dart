import 'method.dart';

/// routing annotiation for route settings
class Route {
  /// the route path
  final String path;

  /// route accepted methods
  final String methods;

  /// routes middlewares
  final List middlewares;

  /// routes middlewares
  final List<String> accepted;

  /// add custom route with custom methods
  const Route(
    this.path,
    this.methods, [
    this.middlewares = const [],
    this.accepted = const [],
  ]);

  /// route with GET method
  const Route.get(
    this.path, [
    this.middlewares = const [],
    this.accepted = const [],
  ]) : methods = ReqMethods.get;

  /// route with POST method
  const Route.post(
    this.path, [
    this.middlewares = const [],
    this.accepted = const [],
  ]) : methods = ReqMethods.post;

  /// route with PUT method
  const Route.put(
    this.path, [
    this.middlewares = const [],
    this.accepted = const [],
  ]) : methods = ReqMethods.put;

  /// route with DELETE method
  const Route.delete(
    this.path, [
    this.middlewares = const [],
    this.accepted = const [],
  ]) : methods = ReqMethods.delete;
}

/// this defines that the method called before the main handler method
class BeforeMW {
  /// this defines that the method called before the main handler method
  const BeforeMW();
}

/// this defines that the method called after the main handler method
class AfterMW {
  /// this defines that the method called after the main handler method
  const AfterMW();
}
