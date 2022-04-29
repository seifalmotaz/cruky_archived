part of './annotation.dart';

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
