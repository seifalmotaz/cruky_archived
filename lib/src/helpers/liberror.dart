import 'dart:mirrors';

class LibError {
  final String msg;
  final String stackTrace;

  LibError(this.msg, this.stackTrace);
  LibError.stack(SourceLocation location, this.msg)
      : stackTrace = LibError.getStackTraceFromLocation(location);

  static getStackTraceFromLocation(SourceLocation location) =>
      "${location.sourceUri.toFilePath()}:${location.line}:${location.column}";
}

class ExceptionRes {
  final Object res;
  final LibError? error;
  ExceptionRes(this.res, [this.error]);
}
