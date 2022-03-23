import 'dart:convert';
import 'package:cruky/helper/string.dart';

class DataParser {
  final dynamic data;
  final dynamic error;
  DataParser(this.data, this.error);
}

dynamic checkType(data, Type type) {
  if (type == List || type == Map) {
    if ((type == List || type == Map) && data is String) {
      return json.decode(data);
    }
    return data;
  }

  if (data is List && type != List) data = data.first;
  if (type == String && data is String) return data;

  /// int type
  if (type == int && data is int) {
    return data;
  } else if (type == int && data is! int) {
    return int.parse(data);
  }

  /// double type
  if (type == double && data is double) {
    return data;
  } else if (type == double && data is! double) {
    return double.parse(data);
  }

  /// bool type
  if (data is bool && type == bool) {
    return data;
  } else if (data is! bool && type == bool) {
    return (data as String).parseBool();
  }
}
