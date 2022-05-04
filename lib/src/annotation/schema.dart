part of './annotation.dart';

/// An annotation for specifying where to get the data and pass it to the annotated class
class Schema {
  /// the accepted content type
  final List<String> accepted;

  /// bind data type
  final BindingType bindingType;

  /// An annotation for spacifiying where to get the data and pass it to the annotated class
  const Schema(this.accepted, this.bindingType);

  /// annotation that accept the json content type
  const Schema.json()
      : accepted = const [MimeTypes.json],
        bindingType = BindingType.json;

  /// annotation that accept the form content type
  const Schema.form()
      : accepted = const [MimeTypes.urlEncodedForm],
        bindingType = BindingType.form;

  /// annotation that accept the multipart form content type
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
