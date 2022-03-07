library cruco.router;

import 'dart:io';
import 'dart:mirrors';

part './types.dart';
part './methods.dart';
part './errors.dart';

class RouterOptions {
  RouterOptions();
}

class Router {
  final List<ErrorRoute> _errs = [];
  final List<TypeRoute> _routes = [];

  TypeRoute matchLib(String path, String method) {
    List<TypeRoute> routes =
        _routes.where((e) => e.match(path, method)).toList();
    if (routes.length == 1) {
      return routes.first;
    } else {
      for (TypeRoute item in routes) {
        print(item.path.regExp);
        if (_pathRegEx(path).regExp == item.path.regExp) return item;
      }
    }

    return _errs.firstWhere((e) => e.statusCode == 404);
  }

  void passLib(RouterOptions options) {}

  void addLib(Symbol symbol, [RouterOptions? options, LibraryMirror? mirror]) {
    LibraryMirror libMI = mirror ?? currentMirrorSystem().findLibrary(symbol);
    List<MethodMirror> methods =
        libMI.declarations.values.whereType<MethodMirror>().toList();
    for (var m in methods) {
      _addMethod(m, libMI);
    }
  }

  PathRegEx _pathRegEx(String path) {
    PathRegEx regex = PathRegEx("^", {});
    List<String> split = path.split('/');
    split.removeWhere((e) => e.isEmpty);
    RegExp parmRegExp = RegExp(r":[a-zA-Z]+\(?([^)]+)?\)?:?");
    RegExp parmTypeRegExp = RegExp(r"\(([^)]*)\)");
    for (var i = 0; i < split.length; i++) {
      String segmant = split[i];
      if (!parmRegExp.hasMatch(segmant)) {
        if (!segmant.startsWith('/')) regex.regExp += '/';
        regex.regExp += segmant;
      } else {
        String parm = parmRegExp.firstMatch(segmant)!.group(0)!;
        String? type = parmTypeRegExp.firstMatch(parm)?.group(0);
        String name = segmant.replaceFirst(type ?? '', '').replaceAll(':', '');

        if (!parm.startsWith('/')) regex.regExp += '/';
        if (type == null) regex.regExp += r"[a-zA-Z0-9_-]+";
        if (type == '(int)') regex.regExp += r"[0-9]+";
        if (type == '(string)') regex.regExp += r"[^0-9]+";
        if (type == '(double)') regex.regExp += r"[0-9]*.[0-9]+";
        regex.parms.addAll({name: i});
      }
    }
    regex.regExp += r'/?$';
    return regex;
  }

  void _addMethod(MethodMirror method, LibraryMirror libMI) {
    PathRegEx path = PathRegEx(".", {});
    String reqMethod = 'GET';
    // get some data
    List<InstanceMirror> metasMI = method.metadata;
    if (metasMI.isEmpty) return;
    for (InstanceMirror meta in metasMI) {
      dynamic reflectee = meta.reflectee;
      if (reflectee is ERoute) {
        _errs.add(ErrorRoute(
          symbol: method.simpleName,
          lib: libMI.simpleName,
          statusCode: reflectee.status,
        ));
        return;
      }
      if (reflectee is Route) {
        path = _pathRegEx(reflectee.path);
        reqMethod = reflectee.method;
        continue;
      }
    }
    // get params values
    List<ParameterMirror> parmsMI = method.parameters.toList();
    Map<Symbol, Type> parms = {};
    for (ParameterMirror parm in parmsMI) {
      parms.addAll({
        parm.simpleName: parm.type.reflectedType,
      });
    }
    _routes.add(MethodRoute(
      method: reqMethod,
      symbol: method.simpleName,
      lib: libMI.simpleName,
      path: path,
      parms: parms,
    ));
  }
}
