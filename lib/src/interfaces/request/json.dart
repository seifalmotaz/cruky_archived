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
  dynamic operator [](String i) => query[i] ?? parameters[i] ?? body[i];
}
