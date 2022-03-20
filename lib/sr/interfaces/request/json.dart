part of cruky.request;

class JsonRequest {
  /// the request uri
  final Uri path;

  /// the request uri query
  final Map query;

  /// path parameters
  final Map parameters;

  // json body if exist
  Map body = {};

  JsonRequest({
    required this.path,
    required this.parameters,
    required this.query,
  });

  dynamic operator [](String i) => query[i] ?? parameters[i] ?? body[i];
}
