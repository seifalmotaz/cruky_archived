import 'dart:mirrors';

/// invoke method,
/// class mirrors new instance
///
/// InFunction for `In`stanse and `In`voke
typedef InFunction = InstanceMirror Function(
  Symbol memberName,
  List<dynamic> positionalArguments, [
  Map<Symbol, dynamic> namedArguments,
]);

/// libs invocation methods
final Map<Symbol, InFunction> libsInvocation = {};

/// global middleware
final Map<String, Function> globalMiddlewares = {};

/// middleware classes
final Map<Type, InFunction> usedMiddlewares = {};
