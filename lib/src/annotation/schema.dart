part of './annotation.dart';

/// __Schema__ class helps you to define how to get the data and validate them
class Schema {
  /// the accepted content type
  final List<String> accepted;

  /// bind data type
  final BindingType bindingType;

  /// __Schema__ class helps you to define how to get the data and validate them
  const Schema(this.accepted, this.bindingType);

  /// this will accept the json content type
  const Schema.json()
      : accepted = const [MimeTypes.json],
        bindingType = BindingType.json;

  /// this will accept the form content type
  const Schema.form()
      : accepted = const [MimeTypes.urlEncodedForm],
        bindingType = BindingType.form;

  /// this will accept the multipart form content type
  const Schema.iform()
      : accepted = const [MimeTypes.multipartForm],
        bindingType = BindingType.iform;
}

enum BindingType {
  json,
  form,
  iform,
  query,
  path,
}

class BindFrom {
  final BindingType from;
  const BindFrom(this.from);
  const BindFrom.json() : from = BindingType.json;
  const BindFrom.form() : from = BindingType.form;
  const BindFrom.iform() : from = BindingType.iform;
  const BindFrom.query() : from = BindingType.query;
  const BindFrom.path() : from = BindingType.path;
}
