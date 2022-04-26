import 'package:cruky/src/common/string_converter.dart';
import 'package:cruky/src/core/res.dart';

/// request query parameters helper that can help you get data easily
class QueryParameters {
  /// the main data that returned fro the request uri
  final Map<String, List<String>> map;

  /// request query parameters helper that can help you get data easily
  QueryParameters(Uri uri) : map = uri.queryParametersAll;

  /// get value as int
  int? getInt(String i) {
    final _data = map[i];
    if (_data == null) return null;
    return _data.first.toInt();
  }

  /// get value as num
  num? getNum(String i) {
    final _data = map[i];
    if (_data == null) return null;
    return _data.first.toNum();
  }

  /// get value as double
  double? getDouble(String i) {
    final _data = map[i];
    if (_data == null) return null;
    return _data.first.toDouble();
  }

  /// get value as bool
  bool? getBool(String i) {
    final _data = map[i];
    if (_data == null) return null;
    String ii = _data.first.toLowerCase();
    return ii.toBool();
  }

  /// get value as bool
  ///
  /// if [required] argument is true then all the list is not null
  List<bool?>? listBool(String i, [bool required = false]) {
    final _data = map[i];
    if (_data == null) {
      throw Json({'msg': 'field $i is required'}, 422);
    }
    return _data.map((e) {
      bool? i2 = e.toLowerCase().toBool();
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
    final _data = map[i];
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
    final _data = map[i];
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
    final _data = map[i];
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
