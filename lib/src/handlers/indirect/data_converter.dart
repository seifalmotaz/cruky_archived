import 'package:cruky/src/helpers/liberror.dart';
import 'package:cruky/src/response/basic.dart';
import 'package:cruky/src/utils/utils.dart';

class DataConverter {
  static Object transformList(List<String> data, Type type) {
    switch (type) {
      case List<int>:
        return data.map((e) {
          int? i = e.toInt();
          if (i == null) {
            throw ExceptionRes(Text(
              '"$data" cannot be an "list int" type',
              422,
            ));
          }
          return i;
        }).toList();
      case List<double>:
        return data.map((e) {
          double? i = e.toDouble();
          if (i == null) {
            throw ExceptionRes(Text(
              '"$data" cannot be an "list double" type',
              422,
            ));
          }
          return i;
        }).toList();
      case List<num>:
        return data.map((e) {
          num? i = e.toNum();
          if (i == null) {
            throw ExceptionRes(Text(
              '"$data" cannot be an "list number" type',
              422,
            ));
          }
          return i;
        }).toList();
      case List<String>:
        return data;
    }
    throw ExceptionRes(Text(
      '"$data" is not subtype of $type',
      422,
    ));
  }

  static Object transformListToType(List<String> data, Type type) {
    switch (type) {
      case int:
        int? i = data.first.toInt();
        if (i == null) {
          throw ExceptionRes(Text(
            '"${data.first}" cannot be an "int" type',
            422,
          ));
        }
        return i;
      case double:
        double? i = data.first.toDouble();
        if (i == null) {
          throw ExceptionRes(Text(
            '"${data.first}" cannot be an "double" type',
            422,
          ));
        }
        return i;
      case num:
        num? i = data.first.toNum();
        if (i == null) {
          throw ExceptionRes(Text(
            '"${data.first}" cannot be an "number" type',
            422,
          ));
        }
        return i;
      case String:
        return data.first;
    }
    throw ExceptionRes(Text(
      '"${data.first}" is not subtype of $type',
      422,
    ));
  }
}
