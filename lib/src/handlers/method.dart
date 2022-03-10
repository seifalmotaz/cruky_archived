part of cruky.handlers;

class MethodHandler extends RequestHandler {
  Symbol lib;
  Symbol method;
  Map<Symbol, Type> params;
  MethodHandler(this.lib, this.method, this.params);

  @override
  dynamic handler(HttpRequest req, Map<Symbol, dynamic> pathParams) async {
    LibraryMirror libraryMirror = currentMirrorSystem().findLibrary(lib);
    final List positionalArguments = [];
    List<Symbol> keys = params.keys.toList();
    for (Symbol key in keys) {
      positionalArguments.add(pathParams[key]);
    }

    // calling method
    var res = libraryMirror.invoke(method, positionalArguments);
    if (res.reflectee is Future) return await res.reflectee;
    return res.reflectee;
  }
}
