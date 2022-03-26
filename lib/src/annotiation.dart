/// annotiation for adding route to method
class Route {
  /// route method (GET, POST, ..etc)
  final String method;

  /// route path
  final String path;

  final List<Type> middlewares;

  /// GET route
  const Route.get(
    this.path, {
    this.method = "GET",
    this.middlewares = const [],
  });

  /// PUT route
  const Route.put(
    this.path, {
    this.method = "PUT",
    this.middlewares = const [],
  });

  /// POST route
  const Route.post(
    this.path, {
    this.method = "POST",
    this.middlewares = const [],
  });

  /// Delete route
  const Route.delete(
    this.path, {
    this.method = "DELETE",
    this.middlewares = const [],
  });
}

/// request body parser annotiation
class Schema {
  /// init
  const Schema();
}
