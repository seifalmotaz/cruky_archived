import 'package:cruky/src/common/string_converter.dart';
import 'package:cruky/src/core/res.dart';

import 'common/file_part.dart';

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
  FilePart? file(String i) => formFiles[i]?.first;

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

  /// get value as bool
  ///
  /// if [required] argument is true then all the list is not null
  List<bool?>? listBool(String i, [bool required = false]) {
    final _data = formFields[i];
    if (_data == null) {
      throw Json({'msg': 'field $i is required'}, 422);
    }
    return _data.map((e) {
      bool? i2 = e.toBool();
      if (i2 == null && required) {
        throw Json({'msg': 'field $i is not a list of booleans'}, 422);
      }
      return i2;
    }).toList();
  }

  /// get value as int
  ///
  /// if [required] argument is true then all the list is not null
  List<int?>? listInt(String i, [bool required = false]) {
    final _data = formFields[i];
    if (_data == null) {
      throw Json({'msg': 'field $i is required'}, 422);
    }
    return _data.map((e) {
      int? i2 = e.toLowerCase().toInt();
      if (i2 == null && required) {
        throw Json({'msg': 'field $i is not a list of integers'}, 422);
      }
      return i2;
    }).toList();
  }

  /// get value as double
  ///
  /// if [required] argument is true then all the list is not null
  List<double?>? listDouble(String i, [bool required = false]) {
    final _data = formFields[i];
    if (_data == null) {
      throw Json({'msg': 'field $i is required'}, 422);
    }
    return _data.map((e) {
      double? i2 = e.toLowerCase().toDouble();
      if (i2 == null && required) {
        throw Json({'msg': 'field $i is not a list of doubles'}, 422);
      }
      return i2;
    }).toList();
  }

  /// get value as num
  ///
  /// if [required] argument is true then all the list is not null
  List<num?>? listNum(String i, [bool required = false]) {
    final _data = formFields[i];
    if (_data == null) {
      throw Json({'msg': 'field $i is required'}, 422);
    }
    return _data.map((e) {
      num? i2 = e.toLowerCase().toNum();
      if (i2 == null && required) {
        throw Json({'msg': 'field $i is not a list of numbers'}, 422);
      }
      return i2;
    }).toList();
  }
}
