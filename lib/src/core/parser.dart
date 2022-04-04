part of cruky.core;

/// This is a class based function to help you
///  add your methods/classes to the routes tree
_RoutesParser use = _RoutesParser();

class _RoutesParser {
  List lib(Function lib) {
    final List<Function> list = [];
    ClosureMirror mirror = reflect(lib) as ClosureMirror;
    LibraryMirror libraryMirror =
        currentMirrorSystem().libraries[mirror.function.location?.sourceUri]!;
    Iterable<MethodMirror> dec =
        libraryMirror.declarations.values.whereType<MethodMirror>();
    for (final method in dec) {
      list.add(libraryMirror.getField(method.simpleName).reflectee);
    }
    return list;
  }
}
