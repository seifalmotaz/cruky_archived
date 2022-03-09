part of cruco.router;

class Route {
  final String method;
  final String path;
  const Route(this.path, [this.method = "GET"]);
  const Route.get(this.path, [this.method = "GET"]);
  const Route.put(this.path, [this.method = "PUT"]);
  const Route.post(this.path, [this.method = "POST"]);
  const Route.delete(this.path, [this.method = "DELETE"]);
}

class ERoute extends Route {
  final int status;
  const ERoute(this.status) : super('/*/**');
}

class CRoute extends Route {
  const CRoute(path, [method = "ALL"]) : super(path, method);
}
