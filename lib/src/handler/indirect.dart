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
    SimpleRequest req = await _getReq(request);

    final List parameters = [];
    for (InParam param in params) {
      if (param is ParserParam) {
        DataParser results = param.parseBody(req);
        if (results.error != null) return results.error;
        var ref = param.newInstance(Symbol.empty, [], results.data);
        parameters.add(ref.reflectee);
        continue;
      }

      final data = req[param.name];
      if (data == null && !param.isOptional) {
        throw {
          #status: 400,
          "msg": "missing field ${param.name}",
        };
      } else {
        if (req is JsonRequest && req[param.name] != null) {
          parameters.add(data);
          continue;
        }
        parameters.add(checkType(data, param.type));
      }
    }
    InstanceMirror result = handler(name, []);
    var reflecte = result.reflectee;
    if (reflecte is Future) reflecte = await reflecte;
    return reflecte;
  }

  Future<SimpleRequest> _getReq(HttpRequest request) async {
    if (requestType == JsonRequest) {
      return await BodyCompiler.json(request, path);
    } else if (requestType == FormRequest) {
      return await BodyCompiler.form(request, path);
    } else if (requestType == iFormRequest) {
      return await BodyCompiler.iForm(request, path);
    } else {
      return BodyCompiler.simple(request, path);
    }
  }
}
