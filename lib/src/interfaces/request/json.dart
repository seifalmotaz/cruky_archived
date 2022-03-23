part of cruky.request;

class JsonRequest extends SimpleRequest {
  /// json body
  Map body = {};

  JsonRequest({
    required path,
    required parameters,
    required query,
    required this.body,
  }) : super(
          parameters: parameters,
          path: path,
          query: query,
        );
  @override
  dynamic operator [](String i) => super[i] ?? body[i];

  @override
  Set call(String i) {
    Set call = super.call(i);
    if (call.first != null) return call;
    dynamic data;
    FieldParser? parser;
    if (body[i] != null) {
      data = body[i];
      parser = FieldParser.json;
    }
    return {data, parser};
  }
}
