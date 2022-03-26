import 'dart:io';

import 'package:cruky/cruky.dart';

/// For adding middleware to methods:
///
/// ```
/// class AuthMW extends Middleware {
///   @override
///   void before() {}
///
///   @override
///   void after() {} // optional
/// }
/// ```
abstract class Middleware {
  /// you can access the response in the `after` method
  late HttpResponse response;

  /// the request data
  ///
  /// It can be `SimpleRequest`, `JsonRequest`, `FormRequest` or `iFormRequest`.
  ///
  /// to know more about request types: [see docs](https://github.com/seifalmotaz/cruky/wiki/Request-types)
  late SimpleReq request;

  /// this method called before the main route method called.
  ///
  /// you can return some data to pass to the main route method.
  /// ```
  /// request.middleware('someKey', 'value');
  /// ```
  bool before();

  /// this method called after the main route method called.
  ///
  /// you can edit the response from the main route method before
  /// closing the request response.
  void after() {}
}
