library cruco.router;

import 'dart:convert';
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

  TypeRoute matchLib(String path, String method) => _routes.firstWhere(
        (e) => e.match(path, method),
        orElse: () => _errs.firstWhere((e) => e.statusCode == 404),
      );

  void passLib(RouterOptions options) {}

  void addLib(Symbol symbol, [RouterOptions? options, LibraryMirror? mirror]) {
    LibraryMirror libMI = mirror ?? currentMirrorSystem().findLibrary(symbol);
    List<MethodMirror> methods =
        libMI.declarations.values.whereType<MethodMirror>().toList();
    for (MethodMirror method in methods) {
      String path = '/';
      String reqMethod = 'GET';
      // get some data
      List<InstanceMirror> metasMI = method.metadata;
      if (metasMI.isEmpty) continue;
      for (InstanceMirror meta in metasMI) {
        dynamic reflectee = meta.reflectee;
        if (reflectee is ERoute) {
          _errs.add(ErrorRoute(
            symbol: method.simpleName,
            lib: libMI.simpleName,
            statusCode: reflectee.status,
          ));
          continue;
        }
        if (reflectee is Route) {
          path = reflectee.path;
          reqMethod = reflectee.method;
        }
      }
      // get params values
      List<ParameterMirror> parmsMI =
          method.parameters.where((e) => e.isNamed).toList();
      Map<String, Type> parms = {};
      for (ParameterMirror parm in parmsMI) {
        parms.addAll({
          parm.simpleName.toString(): parm.type.reflectedType,
        });
      }

      _routes.add(MethodRoute(
        method: reqMethod,
        symbol: method.simpleName,
        lib: libMI.simpleName,
        path: Uri(path: path),
        parms: parms,
      ));
    }
  }
}
