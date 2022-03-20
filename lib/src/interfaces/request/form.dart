part of cruky.request;

class FormRequest extends SimpleRequest {
  /// form fields
  Map form = {};

  FormRequest({
    required Uri path,
    required Map parameters,
    required Map query,
    required this.form,
    parsers = const {},
  }) : super(
          parameters: parameters,
          path: path,
          query: query,
          parsers: parsers,
        );

  @override
  dynamic operator [](String i) => query[i] ?? parameters[i] ?? form[i];
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
    parsers = const {},
  }) : super(
          parameters: parameters,
          path: path,
          query: query,
          parsers: parsers,
        );

  @override
  dynamic operator [](String i) =>
      query[i] ?? parameters[i] ?? form[i] ?? files[i];
}
