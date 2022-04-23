part of cruky.scanner;

class HandlerType<T extends Function> {
  final Type? annotationType;
  final Future Function(
    ClosureMirror handler,
    List<RouteHandler>,
    List<RouteHandler>,
  ) parser;

  HandlerType({
    this.annotationType,
    required this.parser,
  });

  match(Function func) => func is T;
}

class RouteMock {
  final List<String> methods;
  final String path;
  final RouteHandler handler;
  RouteMock({
    required this.path,
    required this.methods,
    required this.handler,
  });
}

class MethodParser {
  final List<RouteMock> list = [];
  // final  HandlerType dynamicType = inDirectHandler;

  final List<HandlerType> types = [
    HandlerType<BaseFunction>(
      parser: BaseHandler.parse,
      annotationType: null,
    ),
  ];

  MethodParser(List<HandlerType> t) {
    types.addAll(t);
  }

  Future<void> addAll(RouteMirror mirror) async {
    for (var route in mirror.routes) {
      var filterMW2 = filterMW(route.pipeline);
      Middleware middleware = mirror.middlware;
      middleware.pre.addAll(filterMW2.pre);
      middleware.post.addAll(filterMW2.post);

      var join = mirror.prefix.map((e) => getPath(e)).join('/');
      if (!join.endsWith('/')) join += '/';
      String routePath = join + getPath(route.path);

      var methods2 = route.methods;
      List<String> methods = methods2.toUpperCase().split(',');
      methods.removeWhere((element) => element.isEmpty);
      methods = methods.map((e) => e.replaceAll(' ', '')).toList();

      RouteHandler result = await parse(mirror.mirror, routePath, middleware);
      list.add(RouteMock(
        handler: result,
        methods: methods,
        path: routePath,
      ));
    }
  }

  String getPath(String e) {
    var split = e.split('/');
    split.removeWhere((e) => e.isEmpty);
    return split.join('/');
  }

  Future<RouteHandler> parse(
    ClosureMirror mirror,
    String path,
    Middleware middleware,
  ) async {
    final List<RouteHandler> preMW = [];
    final List<RouteHandler> postMW = [];

    for (var mw in middleware.pre) {
      preMW.add(await getMwHandler(mw));
    }
    for (var mw in middleware.post) {
      postMW.add(await getMwHandler(mw));
    }

    List<Type> annoTypes = mirror.function.metadata
        .where((e) => e.reflectee is HandlerInfo)
        .map((e) => e.reflectee.runtimeType)
        .toList();

    if (annoTypes.isNotEmpty) {
      try {
        var type = types.firstWhere((e) => e.annotationType == annoTypes.first);
        return await type.parser(mirror, preMW, postMW);
      } on StateError {
        var sourceLocation = mirror.function.location!;
        throw LibError(
          'There is no handler type like ${annoTypes.first}',
          "${sourceLocation.sourceUri.toFilePath()}:${sourceLocation.line}:${sourceLocation.column}",
        );
      }
    }

    for (var item in types) {
      if (item.match(mirror.reflectee)) {
        return await item.parser(mirror, preMW, postMW);
      }
    }

    throw LibError.stack(
      mirror.function.location!,
      'Method of path $path has no handler type',
    );
  }

  Future<RouteHandler> getMwHandler(ClosureMirror mirror) async {
    List<Type> annoTypes = mirror.function.metadata
        .where((e) => e.reflectee is HandlerInfo)
        .map((e) => e.reflectee.runtimeType)
        .toList();

    if (annoTypes.isNotEmpty) {
      try {
        var type = types.firstWhere((e) => e.annotationType == annoTypes.first);
        return await type.parser(mirror, [], []);
      } on StateError {
        var sourceLocation = mirror.function.location!;
        throw LibError(
          'There is no handler type like ${annoTypes.first}',
          "${sourceLocation.sourceUri.toFilePath()}:${sourceLocation.line}:${sourceLocation.column}",
        );
      }
    }

    for (var item in types) {
      if (item.match(mirror.reflectee)) {
        return await item.parser(mirror, [], []);
      }
    }

    throw LibError.stack(
      mirror.function.location!,
      'Middleware function has no handler type',
    );
  }
}
