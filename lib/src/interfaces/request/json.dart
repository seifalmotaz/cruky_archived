part of cruky.request;

class JsonRequest extends SimpleRequest {
  /// json body
  Map body = {};

  JsonRequest({
    required path,
    required parameters,
    required query,
    parsers = const {},
    required this.body,
  }) : super(
          parameters: parameters,
          path: path,
          query: query,
          parsers: parsers,
        );
  @override
  dynamic operator [](String i) =>
      query[i] ?? parameters[i] ?? body[i] ?? parsers[i];
}
