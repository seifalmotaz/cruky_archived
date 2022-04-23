part of cruky.scanner;

class Middleware {
  final List<ClosureMirror> pre = [];
  final List<ClosureMirror> post = [];
}

class RouteMirror {
  final ClosureMirror mirror;
  final Middleware middlware;
  final List<String> prefix;
  final List<Route> routes;
  RouteMirror({
    required this.mirror,
    required this.routes,
    required this.middlware,
    required this.prefix,
  });
}

List<RouteMirror> getRoutesMirrors(ServerApp app) {
  final List<RouteMirror> routes = [];
  final Middleware globalMW = Middleware();

  {
    var i = filterMW(app.middleware);
    globalMW.pre.addAll(i.pre);
    globalMW.post.addAll(i.post);
  }
  routes.addAll(addRoutes(app.routes, globalMW, [app.prefix]));
  for (var item in app.plugins) {
    var i = filterMW(item.middleware);
    globalMW.pre.addAll(i.pre);
    globalMW.post.addAll(i.post);
    routes.addAll(addRoutes(item.routes, globalMW, [app.prefix]));
  }

  return routes;
}

List<RouteMirror> addRoutes(
  List routes,
  Middleware parentMW,
  List<String> prefix,
) {
  List<RouteMirror> list = [];
  for (var route in routes) {
    if (route is Function) {
      var reflect2 = reflect(route) as ClosureMirror;
      if (!reflect2.function.isRegularMethod) continue;
      Iterable<Route> r = reflect2.function.metadata
          .where((e) => e.reflectee is Route)
          .map((e) => e.reflectee);
      if (r.isEmpty) {
        throw LibError.stack(
            reflect2.function.location!,
            'Method "${MirrorSystem.getName(reflect2.function.simpleName)}"'
            ' does not have a `Route` annotation');
      }
      list.add(RouteMirror(
        mirror: reflect2,
        routes: r.toList(),
        middlware: parentMW,
        prefix: prefix,
      ));
      continue;
    }
    if (route is List) {
      list.addAll(addRoutes(route, parentMW, prefix));
      continue;
    }
    if (route is AppMaterial) {
      List<String> prefix2 = prefix + [route.prefix];
      Middleware middleware = Middleware()
        ..pre.addAll(parentMW.pre)
        ..post.addAll(parentMW.post);

      var i = filterMW(route.middleware);
      middleware.pre.addAll(i.pre);
      middleware.post.addAll(i.post);

      list.addAll(addRoutes(route.routes, middleware, prefix2));
      continue;
    }
  }
  return list;
}

Middleware filterMW(List mw) {
  Middleware middleware = Middleware();
  for (var item in mw) {
    var ref = reflect(item) as ClosureMirror;
    var function = ref.function;
    bool? isPre;
    for (var anno in function.metadata) {
      if (anno.reflectee is UsePre) {
        isPre = true;
      } else if (anno.reflectee is UsePost) {
        isPre = false;
      }
    }

    if (isPre != null) {
      if (isPre) middleware.pre.add(ref);
      if (!isPre) middleware.post.add(ref);
    } else {
      throw LibError.stack(
          function.location!,
          'The middleware method named "${MirrorSystem.getName(function.simpleName)}"'
          ' cannot be a middleware without annotation');
    }
  }
  return middleware;
}
