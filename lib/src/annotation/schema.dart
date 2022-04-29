part of './annotation.dart';

/// __Schema__ class helps you to define how to get the data and validate them
class Schema {
  /// the accepted content type
  final List<String> accepted;

  /// __Schema__ class helps you to define how to get the data and validate them
  const Schema(this.accepted);

  /// this will accept the empty content type
  const Schema.none() : accepted = const [];

  /// this will accept the json content type
  const Schema.json() : accepted = const [MimeTypes.json];

  /// this will accept the form content type
  const Schema.form() : accepted = const [MimeTypes.urlEncodedForm];

  /// this will accept the multipart form content type
  const Schema.iform() : accepted = const [MimeTypes.multipartForm];
}

enum _BindingType {
  json,
  form,
  iform,
  query,
  path,
}

class BindFrom {
  final _BindingType from;
  const BindFrom(this.from);
  const BindFrom.json() : from = _BindingType.json;
  const BindFrom.form() : from = _BindingType.form;
  const BindFrom.iform() : from = _BindingType.iform;
  const BindFrom.query() : from = _BindingType.query;
  const BindFrom.path() : from = _BindingType.path;
}
