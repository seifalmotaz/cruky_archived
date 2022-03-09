part of cruco.router;

abstract class TypeRoute {
  PathRegEx path;
  TypeRoute(this.path);

  dynamic handle(HttpRequest req);
  bool match(String reqPath, String reqMethod);
}

class StatefulRoute extends TypeRoute {
  Symbol symbol;
  String method;
  StatefulHandler handler;
  StatefulRoute({
    required PathRegEx path,
    required this.symbol,
    required this.method,
    required this.handler,
  }) : super(path);

  @override
  dynamic handle(HttpRequest req) async => handler.handle(req);

  @override
  bool match(String reqPath, String reqMethod) {
    if (reqMethod != method && method != "ALL") return false;
    return path.match(reqPath);
  }
}

class MethodRoute extends TypeRoute {
  Symbol lib;
  Symbol symbol;
  String method;
  Map<Symbol, Type> parms;
  MethodRoute({
    required PathRegEx path,
    required this.symbol,
    required this.lib,
    required this.method,
    this.parms = const {},
  }) : super(path);

  @override
  bool match(String reqPath, String reqMethod) {
    if (reqMethod != method) return false;
    return path.match(reqPath);
  }

  @override
  dynamic handle(HttpRequest req) async {
    LibraryMirror libraryMirror = currentMirrorSystem().findLibrary(lib);
    List positionalArguments = [];
    List<Symbol> keys = parms.keys.toList();
    List<Type> values = parms.values.toList();
    for (var i = 0; i < parms.length; i++) {
      String? parm = path.getKey(keys[i], req.uri.path);
      if (parm != null) {
        Type type = values[i];
        if (type == int || type.toString() == 'int') {
          positionalArguments.add(int.parse(parm));
          continue;
        } else if (type is double || type.toString() == 'double') {
          positionalArguments.add(double.parse(parm));
          continue;
        } else if (type is String || type.toString() == 'String') {
          positionalArguments.add(parm);
          continue;
        }
      }
    }
    InstanceMirror result = libraryMirror.invoke(symbol, positionalArguments);
    var reflectee = result.reflectee;
    if (reflectee is Future) {
      dynamic data = await result.reflectee;
      return data;
    }
    return reflectee;
  }
}

class ErrorRoute extends TypeRoute {
  Symbol lib;
  Symbol symbol;
  int statusCode;
  ErrorRoute({
    required this.lib,
    required this.symbol,
    required this.statusCode,
  }) : super(PathRegEx(".", {}));

  @override
  bool match(String reqPath, String reqMethod) => true;

  @override
  dynamic handle(HttpRequest req) {
    LibraryMirror libraryMirror = currentMirrorSystem().findLibrary(lib);
    InstanceMirror result = libraryMirror.invoke(symbol, []);
    req.response.statusCode = statusCode;
    return result.reflectee;
  }
}
