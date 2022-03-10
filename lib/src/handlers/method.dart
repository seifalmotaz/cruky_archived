part of cruky.handlers;

class MethodHandler extends RequestHandler {
  Symbol lib;
  Symbol method;
  Map<String, Type> params;
  MethodHandler(this.lib, this.method, this.params);

  @override
  dynamic handler(HttpRequest req, Map<String, dynamic> pathParams) async {
    LibraryMirror libraryMirror = currentMirrorSystem().findLibrary(lib);
    final List positionalArguments = [];
    List<String> keys = params.keys.toList();
    for (String key in keys) {
      // get param data from path params
      var data = pathParams[key];
      if (data != null) positionalArguments.add(data);

      // get param data from json body
      // print(req.headers.contentType == ContentType.json);
      if (req.headers.contentType?.mimeType == ContentType.json.mimeType) {
        Map body = jsonDecode(await utf8.decodeStream(req));
        data = body[key];
        if (data != null) positionalArguments.add(data);
      }
    }
    // calling method
    var res = libraryMirror.invoke(method, positionalArguments);
    if (res.reflectee is Future) return await res.reflectee;
    return res.reflectee;
  }
}
