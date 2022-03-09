library cruco.router;

import 'dart:io';
import 'dart:mirrors';

import 'package:cruco/src/handlers/class.dart';
import 'package:cruco/src/interfaces/path_regex.dart';

part './types.dart';
part './methods.dart';
part './errors.dart';

class RouterOptions {
  RouterOptions();
}

class Router {
  final List<ErrorRoute> errs = [];
  final List<TypeRoute> _routes = [];

  TypeRoute? matchPath(String path, String method) {
    List<TypeRoute> routes =
        _routes.where((e) => e.match(path, method)).toList();
    if (routes.isEmpty) return null;
    if (routes.length == 1) {
      return routes.first;
    } else {
      for (TypeRoute item in routes) {
        if (pathRegEx(path).regExp == item.path.regExp) return item;
      }
    }
    return null;
  }

  void passLib(RouterOptions options) {}

  void addLib(Symbol symbol, [RouterOptions? options, LibraryMirror? mirror]) {
    LibraryMirror libMI = mirror ?? currentMirrorSystem().findLibrary(symbol);
    List<DeclarationMirror> declarations = libMI.declarations.values.toList();
    for (var declaration in declarations) {
      if (declaration.metadata
          .takeWhile((value) => value.reflectee is Route)
          .isEmpty) continue;
      if (declaration is MethodMirror) _addMethod(declaration, libMI);
      if (declaration is ClassMirror) _addClass(declaration, libMI);
    }
  }

  void _addClass(ClassMirror class_, LibraryMirror libMI) {
    PathRegEx path = PathRegEx(".", {});
    String _path = '';
    String reqMethod = 'GET';
    // get some data
    List<InstanceMirror> metasMI = class_.metadata;
    if (metasMI.isEmpty) return;
    for (InstanceMirror meta in metasMI) {
      dynamic reflectee = meta.reflectee;
      if (reflectee is CRoute) {
        _path = reflectee.path;
        path = pathRegEx(reflectee.path, endWith: '/?');
        reqMethod = reflectee.method;
        continue;
      }
    }

    InstanceMirror mirror = class_.newInstance(Symbol(''), []);
    mirror.invoke(#cache, [_path]);
    _routes.add(StatefulRoute(
      method: reqMethod,
      symbol: class_.simpleName,
      path: path,
      handler: mirror.reflectee,
    ));
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
        errs.add(ErrorRoute(
          symbol: method.simpleName,
          lib: libMI.simpleName,
          statusCode: reflectee.status,
        ));
        return;
      }
      if (reflectee is Route) {
        path = pathRegEx(reflectee.path);
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
