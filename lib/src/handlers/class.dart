library cruco.handlers;

import 'dart:io';
import 'dart:mirrors';

import 'package:cruco/src/interfaces/path_regex.dart';
import 'package:cruco/src/router/router.dart';

class _ClassMethodHandler {
  Symbol symbol;
  PathRegEx path;
  String method;
  _ClassMethodHandler({
    required this.method,
    required this.path,
    required this.symbol,
  });

  bool match(String reqPath, String reqMethod) {
    if (reqMethod != method && method != "ALL") return false;
    return path.match(reqPath);
  }
}

class StatefulHandler {
  late String classPath;
  late InstanceMirror _classMirror;
  final List<_ClassMethodHandler> _methods = [];

  cache(String path) {
    List<String> _path = path.split("");
    _path.removeLast();
    classPath = _path.join('/');
    _classMirror = reflect(this);
    ClassMirror classMirror = _classMirror.type;
    Iterable<MethodMirror> methods = classMirror.declarations.values
        .whereType<MethodMirror>()
        .where((e) => !e.isConstructor);

    for (MethodMirror method in methods) {
      PathRegEx path =
          PathRegEx("/${MirrorSystem.getName(method.simpleName)}/?\$", {});

      String reqMethod = 'GET';
      List<InstanceMirror> metasMI = method.metadata;
      for (InstanceMirror meta in metasMI) {
        dynamic reflectee = meta.reflectee;
        if (reflectee is Route) {
          path = pathRegEx(reflectee.path);
          reqMethod = reflectee.method;
          continue;
        }
      }
      _methods.add(_ClassMethodHandler(
        method: reqMethod,
        path: path,
        symbol: method.simpleName,
      ));
    }
  }

  _ClassMethodHandler? _matchMethod(String path, String method) {
    List<_ClassMethodHandler> routes =
        _methods.where((e) => e.match(path, method)).toList();
    if (routes.isEmpty) return null;
    if (routes.length == 1) {
      return routes.first;
    } else {
      for (_ClassMethodHandler item in routes) {
        if (pathRegEx(path).regExp == item.path.regExp) return item;
      }
    }

    return null;
  }

  dynamic handle(HttpRequest req) async {
    String _path = req.uri.path.replaceFirst(classPath, '');
    _ClassMethodHandler? handler = _matchMethod(_path, req.method);
    if (handler == null) return;
    InstanceMirror mirror = _classMirror.invoke(handler.symbol, []);
    var reflectee = mirror.reflectee;
    if (reflectee is Future) {
      dynamic data = await reflectee;
      return data;
    }
    return reflectee;
  }
}
