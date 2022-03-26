part of cruky.request;

class JsonReq extends SimpleReq {
  /// json body
  Map body = {};

  JsonReq({
    required path,
    required parameters,
    required query,
    required this.body,
    required HttpHeaders headers,
  }) : super(
          parameters: parameters,
          path: path,
          headers: headers,
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
