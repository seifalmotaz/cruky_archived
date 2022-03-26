part of cruky.handlers;

class InDirectHandler extends MethodHandler {
  /// method symbol
  final Symbol name;

  /// handle the request my calling the method with mirrors
  final Symbol libHandler;

  /// method params
  final List<InParam> params;

  InDirectHandler({
    required path,
    required method,
    required requestType,
    required this.name,
    required this.libHandler,
    required this.params,
  }) : super(
          method: method,
          path: path,
          requestType: requestType,
        );

  @override
  Future handle(HttpRequest request) async {
    SimpleReq req = await _getReq(request);
    return await _callMethod(req);
  }

  Future<dynamic> _callMethod(SimpleReq req) async {
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
        if (req is JsonReq && req[param.name] != null) {
          parameters.add(data);
          continue;
        }
        parameters.add(checkType(data, param.type));
      }
    }
    InstanceMirror result = libsInvocation[libHandler]!(name, parameters);
    var reflecte = result.reflectee;
    if (reflecte is Future) reflecte = await reflecte;
    return reflecte;
  }

  Future<SimpleReq> _getReq(HttpRequest request) async {
    if (requestType == JsonReq) {
      return await BodyCompiler.json(request, path);
    } else if (requestType == FormReq) {
      return await BodyCompiler.form(request, path);
    } else if (requestType == iFormReq) {
      return await BodyCompiler.iForm(request, path);
    } else {
      return BodyCompiler.simple(request, path);
    }
  }
}
