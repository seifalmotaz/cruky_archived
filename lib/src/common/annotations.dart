import 'package:cruky/cruky.dart';

import 'enum.dart';

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

  /// route with GET method
  const Route.jget(
    this.path, [
    this.middlewares = const [],
  ])  : methods = ReqMethods.get,
        accepted = const [MimeTypes.json];

  /// route with POST method
  const Route.jpost(
    this.path, [
    this.middlewares = const [],
  ])  : methods = ReqMethods.post,
        accepted = const [MimeTypes.json];

  /// route with PUT method
  const Route.jput(
    this.path, [
    this.middlewares = const [],
  ])  : methods = ReqMethods.put,
        accepted = const [MimeTypes.json];

  /// route with DELETE method
  const Route.jdelete(
    this.path, [
    this.middlewares = const [],
  ])  : methods = ReqMethods.delete,
        accepted = const [MimeTypes.json];
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
