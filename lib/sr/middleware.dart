import 'handlers/handlers.dart';
import 'interfaces/request/request.dart';

/// This an annotiation to add middlewares to route method
///
/// You can define a middleware with `MiddlewareHandler`
class Middleware {
  /// List of `MiddlewareHandler` type for middleware handling
  final List<Type> handlers;
  const Middleware(this.handlers);
}

abstract class MiddlewareHandler {
  late JsonRequest request;

  /// This is a function that called before thr route main method
  /// and you can parse a parameters as type of map
  ///
  /// if you want to return error and not calling the main method
  /// add error symbol to the returned map
  Future<Map> main();
}

class MiddlewareMap {
  Type type;
  List<MethodParam> params;
  MiddlewareMap({
    required this.type,
    required this.params,
  });
}
