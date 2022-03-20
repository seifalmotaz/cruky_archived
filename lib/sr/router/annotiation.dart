class Route {
  final String method;
  final String path;
  final bool justFast;
  const Route.get(this.path, {this.method = "GET", this.justFast = false});
  const Route.put(this.path, {this.method = "PUT", this.justFast = false});
  const Route.post(this.path, {this.method = "POST", this.justFast = false});
  const Route.delete(this.path,
      {this.method = "DELETE", this.justFast = false});
  //
  const Route(this.path, this.method, this.justFast);
  const Route.get_(this.path, {this.method = "GET", this.justFast = true});
  const Route.put_(this.path, {this.method = "PUT", this.justFast = true});
  const Route.post_(this.path, {this.method = "POST", this.justFast = true});
  const Route.delete_(this.path,
      {this.method = "DELETE", this.justFast = true});
}
