library cruky.constants;

import 'handlers/routes/schema/parser.dart';

/// globl variable that hlps you to know the server debug mode
late final bool kIsDebug;

final Map<Type, SchemaType> schemaTypes = {};

/// request method types
class ReqMethods {
  static const String get = 'GET';
  static const String post = 'POST';
  static const String put = 'PUT';
  static const String delete = 'DELETE';
}
