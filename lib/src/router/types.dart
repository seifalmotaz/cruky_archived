part of cruco.router;

abstract class TypeRoute {
  Uri path;
  TypeRoute(this.path);

  dynamic execute(HttpRequest req);
  bool match(String reqPath, String reqMethod);
}

class MethodRoute extends TypeRoute {
  Symbol lib;
  Symbol symbol;
  String method;
  Map<String, Type> parms;
  MethodRoute({
    required this.symbol,
    required this.lib,
    required this.method,
    this.parms = const {},
    path,
  }) : super(path);

  @override
  bool match(String reqPath, String reqMethod) {
    if (reqMethod != method) return false;
    List<String> pathS = path.pathSegments;
    List<String> reqPathS = Uri(path: reqPath).pathSegments;
    if (pathS.length != reqPathS.length) return false;
    for (var i = 0; i < reqPathS.length; i++) {
      String reqSegmant = reqPathS[i];
      String pathSegmant = pathS[i];
      if (reqSegmant != pathSegmant) return false;
    }
    return true;
  }

  @override
  dynamic execute(HttpRequest req) async {
    LibraryMirror libraryMirror = currentMirrorSystem().findLibrary(lib);
    InstanceMirror result = libraryMirror.invoke(symbol, []);
    if (result.reflectee is Future) {
      dynamic data = await result.reflectee;
      req.response.write(jsonEncode(data));
      return data;
    }
    req.response.write(jsonEncode(result.reflectee));
    return result.reflectee;
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
  }) : super(Uri(path: '/*/**'));

  @override
  bool match(String reqPath, String reqMethod) => true;

  @override
  dynamic execute(HttpRequest req) {
    LibraryMirror libraryMirror = currentMirrorSystem().findLibrary(lib);
    InstanceMirror result = libraryMirror.invoke(symbol, []);
    req.response.statusCode = statusCode;
    req.response.write(jsonEncode(result.reflectee));
    return result.reflectee;
  }
}
