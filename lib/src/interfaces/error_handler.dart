class ErrorHandler {
  String name;
  String where;
  int status;
  String error;
  dynamic msg;

  ErrorHandler({
    this.name = 'Error handler',
    this.where = 'In request',
    this.error = 'The error',
    this.status = 500,
    this.msg,
  });

  get json => {
        #status: status,
        "name": name,
        "where": where,
        "error": error,
        "msg": msg,
      };
}
