part of cruky.request;

class FormReq extends SimpleReq {
  /// form fields
  Map form = {};

  FormReq({
    required Uri path,
    required Map parameters,
    required Map query,
    required this.form,
    required HttpHeaders headers,
  }) : super(
          parameters: parameters,
          path: path,
          headers: headers,
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
class iFormReq extends SimpleReq {
  /// form fields
  Map<String, String> form = {};

  /// form files
  Map<String, FilePart> files = {};

  iFormReq({
    required Uri path,
    required Map parameters,
    required Map query,
    required this.form,
    required this.files,
    required HttpHeaders headers,
  }) : super(
          parameters: parameters,
          path: path,
          headers: headers,
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
