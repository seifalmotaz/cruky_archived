part of cruky.request;

class FormRequest extends SimpleRequest {
  /// form fields
  Map form = {};

  FormRequest({
    required Uri path,
    required Map parameters,
    required Map query,
    required this.form,
  }) : super(
          parameters: parameters,
          path: path,
          query: query,
        );

  @override
  dynamic operator [](String i) => super[i] ?? form[i];

  @override
  Set call(String i) {
    Set call = super.call(i);
    if (call.first != null) return call;
    dynamic data;
    FieldParser? parser;
    if (form[i] != null) {
      data = form[i];
      parser = FieldParser.form;
    }
    return {data, parser};
  }
}

// ignore: camel_case_types
class iFormRequest extends SimpleRequest {
  /// form fields
  Map<String, String> form = {};

  /// form files
  Map<String, FilePart> files = {};

  iFormRequest({
    required Uri path,
    required Map parameters,
    required Map query,
    required this.form,
    required this.files,
  }) : super(
          parameters: parameters,
          path: path,
          query: query,
        );

  @override
  dynamic operator [](String i) => super[i] ?? form[i] ?? files[i];

  @override
  Set call(String i) {
    Set call = super.call(i);
    if (call.first != null) return call;
    dynamic data;
    FieldParser? parser;
    if (form[i] != null) {
      data = form[i];
      parser = FieldParser.form;
    }
    if (files[i] != null) {
      data = files[i];
      parser = FieldParser.files;
    }
    return {data, parser};
  }
}
