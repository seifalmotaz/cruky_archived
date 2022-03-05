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

  void get(Map Function(CrucoRequest req) on) => _linkees.add(LinkeeMethod(
        method: 'GET',
        on: on,
        middlewares: _currentMiddleware,
        path: _currentPath,
        isAsync: false,
      ));

  void post(Map Function(CrucoRequest req) on) => _linkees.add(LinkeeMethod(
        method: 'POST',
        on: on,
        middlewares: _currentMiddleware,
        path: _currentPath,
        isAsync: true,
      ));

  void getAsync(Future<Map> Function(CrucoRequest req) on) =>
      _linkees.add(LinkeeMethod(
        method: 'GET',
        on: on,
        middlewares: _currentMiddleware,
        path: _currentPath,
        isAsync: true,
      ));

  void postAsync(Future<Map> Function(CrucoRequest req) on) =>
      _linkees.add(LinkeeMethod(
        method: 'POST',
        on: on,
        middlewares: _currentMiddleware,
        path: _currentPath,
        isAsync: false,
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
