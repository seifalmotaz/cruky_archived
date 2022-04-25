import 'package:cruky/src/common/string_converter.dart';

import 'file_part.dart';

/// form data
class FormData {
  final Map<String, List<String>> formFields;
  List? operator [](String i) => formFields[i];
  FormData(this.formFields);
}

/// multipart form data
// ignore: camel_case_types
class iFormData extends FormData {
  final Map<String, List<FilePart>> formFiles;

  @override
  List? operator [](String i) => formFields[i] ?? formFiles[i];
  FilePart? getFile(String i) => formFiles[i]?.first;

  iFormData(formFields, this.formFiles) : super(formFields);
}

extension GetData on FormData {
  /// get value of field as [int]
  String? getString(String name) => formFields[name]?.first;

  /// get value of field as [int]
  int? getInt(String name) => formFields[name]?.first.toInt();

  /// get value of field as [doubel]
  double? getDouble(String name) => formFields[name]?.first.toDouble();

  /// get value of field as [num]
  num? getNum(String name) => formFields[name]?.first.toNum();

  /// get value of field as [Map]
  Map? getMap(String name) => formFields[name]?.first.toMap();

  /// get value of field as [bool]
  bool? getBool(String name) => formFields[name]?.first.toBool();
}
