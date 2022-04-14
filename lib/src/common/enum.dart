/// this helps you to define from where you want to get the parameter from
///
/// like from the json, form or multipart form or you can use headers.
enum BindFrom {
  json,
  form,
  iForm,
  headers,
  query,
}

/// request method types
class ReqMethods {
  static const String get = 'GET';
  static const String post = 'POST';
  static const String put = 'PUT';
  static const String delete = 'DELETE';
}
