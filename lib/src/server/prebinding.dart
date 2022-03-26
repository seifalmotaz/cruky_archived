part of cruky.server;

/// prebinding methods that helps to start the server
extension PreBinding on Cruky {
  /// adding library to server routes with symbol or uri
  /// ```dart
  /// Cruky().passLib(#todoLibrary)
  /// ```
  void lib(Symbol symbol) => _addLib(currentMirrorSystem().findLibrary(symbol));

  /// add library routes to routes
  void _addLib(LibraryMirror lib) {
    libsInvocation.addAll({lib.simpleName: lib.invoke});
    for (final declaration in lib.declarations.entries) {
      final value = declaration.value;

      /// check if it's a route handler method
      if (value.metadata.where((value) => value.reflectee is Route).isEmpty) {
        continue;
      }
      if (value is MethodMirror) _addMethod(value, lib);
    }
  }

  void use(Type middleware) {}

  void _addMethod(MethodMirror methodMirror, LibraryMirror lib) {
    late String method;
    late PathRegex path;
    late Type requestType;

    /// get the required data to add the route to listener
    for (InstanceMirror item in methodMirror.metadata) {
      var reflectee = item.reflectee;
      if (reflectee is Route) {
        method = reflectee.method;
        path = pathRegEx(reflectee.path, endWith: true);
      }
    }

    /// get method required params
    // MethodParams methodParams = MethodParams();
    List<ParameterMirror> paramsMI = methodMirror.parameters;

    // final simpleReqReflect = reflectType(SimpleReq);
    // final resCTXReflect = reflectType(ResCTX);
    requestType = paramsMI.first.type.reflectedType;

    // if (requestType == null) {
    //   throw ArgumentError('The method for method: ${methodMirror.simpleName} '
    //       'does not have a SimpleReq class in the first argument');
    // }

    routes.add(DirectHandler(
      path: path,
      method: method,
      requestType: requestType,
      handler: lib.getField(methodMirror.simpleName).reflectee,
    ));
  }
}
