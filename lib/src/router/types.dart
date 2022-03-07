part of cruco.router;

class PathRegEx {
  String regExp;
  Map<String, int> parms;
  PathRegEx(this.regExp, this.parms);

  match(String path) => RegExp(regExp).hasMatch(path);

  String? getKey(Symbol key, String path) {
    List<String> split = path.split('/');
    split.removeWhere((e) => e.isEmpty);
    List<String> keys = parms.keys.toList();
    List<int> values = parms.values.toList();
    for (var i = 0; i < parms.length; i++) {
      if (Symbol(keys[i]) != key) continue;
      return split[values[i]];
    }
    return null;
  }
}

abstract class TypeRoute {
  PathRegEx path;
  TypeRoute(this.path);

  dynamic execute(HttpRequest req);
  bool match(String reqPath, String reqMethod);
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
    // List<String> pathS = path.pathSegments;
    // List<String> reqPathS = Uri(path: reqPath).pathSegments;
    // if (pathS.length != reqPathS.length) return false;
    // for (var i = 0; i < reqPathS.length; i++) {
    //   String reqSegmant = reqPathS[i];
    //   String pathSegmant = pathS[i];
    //   if (reqSegmant != pathSegmant) return false;
    // }
    return path.match(reqPath);
  }

  @override
  dynamic execute(HttpRequest req) async {
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
    if (result.reflectee is Future) {
      dynamic data = await result.reflectee;
      return data;
    }
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
  }) : super(PathRegEx(".", {}));

  @override
  bool match(String reqPath, String reqMethod) => true;

  @override
  dynamic execute(HttpRequest req) {
    LibraryMirror libraryMirror = currentMirrorSystem().findLibrary(lib);
    InstanceMirror result = libraryMirror.invoke(symbol, []);
    req.response.statusCode = statusCode;
    return result.reflectee;
  }
}
