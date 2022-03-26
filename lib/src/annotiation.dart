/// annotiation for adding route to method
class Route {
  /// route method (GET, POST, ..etc)
  final String method;

  /// route path
  final String path;

  /// valide request handler
  final Type? contentType;

  /// GET route
  const Route.get(this.path, {this.method = "GET", this.contentType});

  /// PUT route
  const Route.put(this.path, {this.method = "PUT", this.contentType});

  /// POST route
  const Route.post(this.path, {this.method = "POST", this.contentType});

  /// Delete route
  const Route.delete(this.path, {this.method = "DELETE", this.contentType});
}

/// Parser from field
///
/// This helps you to spacify from where to get the fields of parser model
enum Bind {
  any,
  body,
  query,
  pathParameters,
}

/// request body parser annotiation
class Schema {
  const Schema();
}
