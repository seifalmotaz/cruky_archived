/// annotiation for adding route to method
class Route {
  final String method;
  final String path;
  const Route.get(this.path, {this.method = "GET"});
  const Route.put(this.path, {this.method = "PUT"});
  const Route.post(this.path, {this.method = "POST"});
  const Route.delete(this.path, {this.method = "DELETE"});
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
class Parser {
  final String name;
  final Bind from;
  const Parser(this.name, [this.from = Bind.any]);
}
