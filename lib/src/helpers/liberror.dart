class LibError {
  final String msg;
  final String stackTrace;

  LibError(this.msg, this.stackTrace);
}

class ExceptionRes {
  final Object res;
  final LibError? error;
  ExceptionRes(this.res, [this.error]);
}
