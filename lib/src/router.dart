part of server;

class Router {
  String _currentPath = '';
  List _currentMiddleware = [];
  final List<Linkee> _linkees = [];

  Router path(String path) {
    _currentPath = path;
    _currentMiddleware = [];
    return this;
  }

  Router middleware(Middleware middleware) {
    _currentMiddleware.add(middleware);
    return this;
  }

  bool _checkMethodType(Function(CrucoRequest req) f) {
    ClosureMirror mi = reflect(f) as ClosureMirror;
    MethodMirror fm = mi.function;
    Type type = fm.returnType.reflectedType;
    if (type == Future<Map>) {
      return true;
    } else if (type == Future<MapResponse>) {
      return true;
    } else if (type == Map || type == MapResponse) {
      return false;
    }

    throw Exception(
        'Path: $_currentPath -> $type\nThe method return type is not avaliable.');
  }

  void get(Function(CrucoRequest req) on) => _linkees.add(LinkeeMethod(
        method: 'GET',
        on: on,
        middlewares: _currentMiddleware,
        path: _currentPath,
        isAsync: _checkMethodType(on),
      ));

  void post(Function(CrucoRequest req) on) => _linkees.add(LinkeeMethod(
        method: 'POST',
        on: on,
        middlewares: _currentMiddleware,
        path: _currentPath,
        isAsync: _checkMethodType(on),
      ));

  Linkee _match(String path, String method) => _linkees.firstWhere(
        (e) => e.path == path && (e.method == method || e.method == 'ALL'),
        orElse: () => LinkeeMethod(
          method: method,
          on: (req) => {#status: HttpStatus.notFound, "msg": "Not found"},
          middlewares: _currentMiddleware,
          path: path,
          isAsync: false,
        ),
      );
}
