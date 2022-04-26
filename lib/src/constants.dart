library cruky.constants;

import 'package:cruky/src/errors/status_errors.dart';

/// globl variable that hlps you to know the server debug mode
bool kIsDebug = true;
late StatusCodes kStatus;

/// request method types
class ReqMethods {
  static const String get = 'GET';
  static const String post = 'POST';
  static const String put = 'PUT';
  static const String delete = 'DELETE';
}
