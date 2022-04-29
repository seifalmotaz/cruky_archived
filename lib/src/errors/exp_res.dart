import 'package:cruky/src/core/res.dart';

class ExpRes {
  final Object res;
  const ExpRes(this.res);
}

class ERes {
  static Json e500([String? msg]) {
    return Json({
      "status code": 500,
      "name": "Server error",
      if (msg != null) "details": msg,
    }, 500);
  }

  static Json e405([String? msg]) {
    return Json({
      "status code": 405,
      "name": "Method not allowed",
      if (msg != null) "details": msg,
    }, 405);
  }

  static Json e415([String? msg]) {
    return Json({
      "status code": 415,
      "name": "Unsupported Media Type",
      if (msg != null) "details": msg,
    }, 415);
  }
}
