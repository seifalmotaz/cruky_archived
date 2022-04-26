library cruky.annotation;

import 'common/mimetypes.dart';
import 'constants.dart';

/// handler for handlers annotations
class HandlerInfo {
  const HandlerInfo();
}

/// this defines that the method called before the main handler method
class UsePre {
  /// this defines that the method called before the main handler method
  const UsePre();
}

/// this defines that the method called after the main handler method
class UsePost {
  /// this defines that the method called after the main handler method
  const UsePost();
}

/// method pipeline instead of using the [Route] pipeline
class Pipeline {
  /// route middleware
  final List pipeline;

  /// method pipeline instead of using the [Route] pipeline
  const Pipeline(this.pipeline);
}

/// routing annotation for route settings
class Route {
  /// the route path
  final String path;

  /// route accepted methods
  final String methods;

  /// route middleware
  final List pipeline;

  /// route accepted content types
  final List<String> accepted;

  /// add custom route with custom methods
  const Route(
    this.path,
    this.methods, {
    this.pipeline = const [],
    this.accepted = const [
      MimeTypes.json,
      MimeTypes.xhtml,
      MimeTypes.txt,
      MimeTypes.binary,
      MimeTypes.multipartForm,
      MimeTypes.urlEncodedForm,
    ],
  });

  /// route with GET method
  const Route.get(
    this.path, {
    this.pipeline = const [],
    this.accepted = const [
      MimeTypes.json,
      MimeTypes.xhtml,
      MimeTypes.txt,
      MimeTypes.binary,
      MimeTypes.multipartForm,
      MimeTypes.urlEncodedForm,
    ],
  }) : methods = ReqMethods.get;

  /// route with POST method
  const Route.post(
    this.path, {
    this.pipeline = const [],
    this.accepted = const [
      MimeTypes.json,
      MimeTypes.xhtml,
      MimeTypes.txt,
      MimeTypes.binary,
      MimeTypes.multipartForm,
      MimeTypes.urlEncodedForm,
    ],
  }) : methods = ReqMethods.post;

  /// route with PUT method
  const Route.put(
    this.path, {
    this.pipeline = const [],
    this.accepted = const [
      MimeTypes.json,
      MimeTypes.xhtml,
      MimeTypes.txt,
      MimeTypes.binary,
      MimeTypes.multipartForm,
      MimeTypes.urlEncodedForm,
    ],
  }) : methods = ReqMethods.put;

  /// route with DELETE method
  const Route.delete(
    this.path, {
    this.pipeline = const [],
    this.accepted = const [
      MimeTypes.json,
      MimeTypes.xhtml,
      MimeTypes.txt,
      MimeTypes.binary,
      MimeTypes.multipartForm,
      MimeTypes.urlEncodedForm,
    ],
  }) : methods = ReqMethods.delete;
}
