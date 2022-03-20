part of cruky.handlers;

class FastHandler extends RequestHandler {
  Symbol lib;
  Symbol method;
  FastHandler(
    this.lib,
    this.method,
    List<MiddlewareMap> middlewares,
  ) : super(middlewares);

  @override
  handler({
    required HttpRequest req,
    required Map<String, dynamic> pathParams,
    required Map<String, dynamic> pathQuery,
  }) async {
    // calling method
    try {
      LibraryMirror libraryMirror = currentMirrorSystem().findLibrary(lib);
      JsonRequest request = JsonRequest(
        parameters: pathParams,
        path: req.uri,
        query: pathQuery,
      );
      if (req.headers.contentType != null) {
        if (req.headers.contentType?.mimeType == ReqHeader.jsonType) {
          String stringBody = await utf8.decodeStream(req);
          if (stringBody.isEmpty) {
            return {
              #status: 500,
              "msg": "json body is not defined",
            };
          }
          request.body = jsonDecode(stringBody);
        }
      }
      var res = libraryMirror.invoke(method, [request]);
      if (res.reflectee is Future) return await res.reflectee;
      return res.reflectee;
    } catch (e) {
      print(e.toString());
      return {#status: 500, "error": e.toString()};
    }
  }
}
