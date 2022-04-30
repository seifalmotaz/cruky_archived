import 'package:cruky/src/core/res.dart';

class ExpRes {
  final Object res;
  const ExpRes(this.res);
}

class ERes {
  static Json e400([Object? msg]) {
    return Json({
      "status code": 400,
      "name": "Bad Request",
      if (msg != null) "details": msg,
    }, 400);
  }

  static Json e404([Object? msg]) {
    return Json({
      "status code": 404,
      "name": "Not found",
      if (msg != null) "details": msg,
    }, 404);
  }

  static Json e405([Object? msg]) {
    return Json({
      "status code": 405,
      "name": "Method not allowed",
      if (msg != null) "details": msg,
    }, 405);
  }

  static Json e406([Object? msg]) {
    return Json({
      "status code": 4046,
      "name": "Not acceptable",
      if (msg != null) "details": msg,
    }, 4046);
  }

  static Json e415([Object? msg]) {
    return Json({
      "status code": 415,
      "name": "Unsupported Media Type",
      if (msg != null) "details": msg,
    }, 415);
  }

  static Json e422([Object? msg]) {
    return Json({
      "status code": 422,
      "name": "Unsupported Media Type",
      if (msg != null) "details": msg,
    }, 422);
  }

  static Json e500([Object? msg]) {
    return Json({
      "status code": 500,
      "name": "Server error",
      if (msg != null) "details": msg,
    }, 500);
  }
}
