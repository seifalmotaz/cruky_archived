part of cruky.handlers;

class InDirectHandler extends MethodHandler {
  /// method symbol
  final Symbol name;

  /// handle the request my calling the method with mirrors
  final InstanceMirror Function(
    Symbol memberName,
    List<dynamic> positionalArguments, [
    Map<Symbol, dynamic> namedArguments,
  ]) handler;
  final List<InParam> params;

  InDirectHandler({
    required path,
    required method,
    required requestType,
    required this.name,
    required this.handler,
    required this.params,
  }) : super(
          method: method,
          path: path,
          requestType: requestType,
        );

  @override
  Future handle(HttpRequest request) async {
    late SimpleRequest req;
    if (requestType == JsonRequest) {
      req = await BodyCompiler.json(request, path);
    } else if (requestType == FormRequest) {
      req = await BodyCompiler.form(request, path);
    } else if (requestType == iFormRequest) {
      List result = await BodyCompiler.iForm(request, path);
      if (result[0] != null) return result[0];
      req = result[1];
    } else {
      req = BodyCompiler.simple(request, path);
    }

    final List parameters = [];
    for (InParam param in params) {
      final data = req[param.name];
      if (data == null && !param.isOptional) {
        return {
          #status: 400,
          "msg": "missing field ${param.name}",
        };
      } else {
        parameters.add(data);
      }
    }
    InstanceMirror result = handler(name, parameters);
    var reflecte = result.reflectee;
    if (reflecte is Future) reflecte = await reflecte;
    return reflecte;
  }
}
