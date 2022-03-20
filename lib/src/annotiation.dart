/// annotiation for adding route to method
class Route {
  final String method;
  final String path;
  const Route.get(this.path, {this.method = "GET"});
  const Route.put(this.path, {this.method = "PUT"});
  const Route.post(this.path, {this.method = "POST"});
  const Route.delete(this.path, {this.method = "DELETE"});
}

/// request body parser annotiation
class Parser {
  final String name;
  const Parser(this.name);
}

/// annotiation for adding parsers to method
class ModelParser {
  final List<Type> parsers;
  const ModelParser(this.parsers);
}
