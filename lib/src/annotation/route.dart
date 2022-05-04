part of './annotation.dart';

/// routing annotation for route settings
class Route {
  /// the route path
  final String path;

  /// route accepted methods
  final String methods;

  /// route middleware
  final List pipeline;

  /// route accepted content types
  final List<String> accepted;

  /// add custom route with custom methods
  const Route(
    this.path,
    this.methods, {
    this.pipeline = const [],
    this.accepted = const [],
  });

  /// route with GET method
  const Route.ws(
    this.path, {
    this.pipeline = const [],
    this.accepted = const [],
  }) : methods = ReqMethods.get;

  /// route with GET method
  const Route.get(
    this.path, {
    this.pipeline = const [],
    this.accepted = const [],
  }) : methods = ReqMethods.get;

  /// route with POST method
  const Route.post(
    this.path, {
    this.pipeline = const [],
    this.accepted = const [],
  }) : methods = ReqMethods.post;

  /// route with PUT method
  const Route.put(
    this.path, {
    this.pipeline = const [],
    this.accepted = const [],
  }) : methods = ReqMethods.put;

  /// route with DELETE method
  const Route.delete(
    this.path, {
    this.pipeline = const [],
    this.accepted = const [],
  }) : methods = ReqMethods.delete;
}
