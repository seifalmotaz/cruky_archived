import 'package:cruky/src/core/res.dart';

class ExpRes {
  final Object res;
  const ExpRes(this.res);
}

class ERes {
  static Json e404([String? msg]) {
    return Json({
      "status code": 404,
      "name": "Not found",
      if (msg != null) "details": msg,
    }, 404);
  }

  static Json e405([String? msg]) {
    return Json({
      "status code": 405,
      "name": "Method not allowed",
      if (msg != null) "details": msg,
    }, 405);
  }

  static Json e406([String? msg]) {
    return Json({
      "status code": 4046,
      "name": "Not acceptable",
      if (msg != null) "details": msg,
    }, 4046);
  }

  static Json e415([String? msg]) {
    return Json({
      "status code": 415,
      "name": "Unsupported Media Type",
      if (msg != null) "details": msg,
    }, 415);
  }

  static Json e500([String? msg]) {
    return Json({
      "status code": 500,
      "name": "Server error",
      if (msg != null) "details": msg,
    }, 500);
  }
}
