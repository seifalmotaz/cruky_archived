part of cruky.server;

class RoutesList {
  final List<RouteMatch> _routes = [];

  MiddlewareMap _getMiddleware(ClassMirror mirror) {
    MethodMirror declarationMirror = mirror.declarations.values
        .whereType<MethodMirror>()
        .firstWhere((e) => e.simpleName == mirror.simpleName);
    Iterable<ParameterMirror> paramsMI = declarationMirror.parameters;
    List<MethodParam> params = [];
    for (ParameterMirror parm in paramsMI) {
      params.add(MethodParam(
        name: MirrorSystem.getName(parm.simpleName),
        type: parm.type.reflectedType,
        isOptional: parm.isOptional,
      ));
    }
    return MiddlewareMap(
      type: mirror.reflectedType,
      params: params,
    );
  }

  void _addMethod(MethodMirror declaration) {
    late String method;
    bool justFast = false;
    late PathRegex path;
    List<MiddlewareMap> middlewares = [];
    // get metadata
    for (InstanceMirror item in declaration.metadata) {
      var reflectee = item.reflectee;
      if (reflectee is Route) {
        method = reflectee.method;
        justFast = reflectee.justFast;
        path = pathRegEx(reflectee.path);
      } else if (reflectee is Middleware) {
        for (Type item in reflectee.handlers) {
          middlewares.add(_getMiddleware(reflectClass(item)));
        }
      }
    }
    if (justFast) {
      _routes.add(MethodRoute(
        path: path,
        method: method,
        methodHandler: FastHandler(
          declaration.owner!.simpleName,
          declaration.simpleName,
          middlewares,
        ),
      ));
      return;
    }
    // get method required params
    List<ParameterMirror> paramsMI = declaration.parameters;
    List<MethodParam> params = [];
    for (ParameterMirror parm in paramsMI) {
      params.add(MethodParam(
        name: MirrorSystem.getName(parm.simpleName),
        type: parm.type.reflectedType,
        isOptional: parm.isOptional,
      ));
    }
    // add method route to _routes
    _routes.add(MethodRoute(
      path: path,
      method: method,
      methodHandler: MethodHandler(
        declaration.owner!.simpleName,
        declaration.simpleName,
        params,
        middlewares,
      ),
    ));
  }
}
