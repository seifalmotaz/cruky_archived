import 'package:cruky/cruky.dart';

/// For adding middleware to methods:
///
/// ```
/// class AuthMW extends Middleware {
///   @override
///   bool before() { // optional
///     return true;
///   }
///
///   @override
///   void after() {} // optional
/// }
/// ```
abstract class Middleware {
  /// the response data
  late ResCTX response;

  /// the request data
  ///
  /// It can be `SimpleReq`, `JsonReq`, `FormReq` or `iFormReq`.
  ///
  /// to know more about request types: [see docs](https://github.com/seifalmotaz/cruky/wiki/Request-types)
  late SimpleReq request;

  /// this method called before the main route method called.
  ///
  /// you can add some data to pass to the main route method:
  /// ```
  /// request.middleware('someKey', 'value');
  /// ```
  bool before() => true;

  /// this method called after the main route method called.
  ///
  /// you can edit the response from the main route method before
  /// closing the request response.
  void after() {}
}
