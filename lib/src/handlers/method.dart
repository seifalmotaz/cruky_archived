part of cruky.handlers;

class MethodHandler extends RequestHandler {
  Symbol lib;
  Symbol method;
  List<MethodParam> params;
  MethodHandler(this.lib, this.method, this.params);

  @override
  dynamic handler({
    required HttpRequest req,
    required Map<String, dynamic> pathParams,
    required Map<String, dynamic> pathQuery,
    required ReqHeader contentType,
  }) async {
    LibraryMirror libraryMirror = currentMirrorSystem().findLibrary(lib);
    final List positionalArguments = [];
    if (params.isNotEmpty) {
      if (req.headers.contentType != null) {
        if (contentType.contentType == ReqHeader.jsonType) {
          String stringBody = await utf8.decodeStream(req);
          if (stringBody.isEmpty) {
            return {
              #status: 500,
              "msg": "json body is not defined",
            };
          }
          Map body = jsonDecode(stringBody);
          for (MethodParam key in params) {
            // get param data from path params
            var data = pathParams[key.name];
            if (data != null) {
              positionalArguments.add(data);
              continue;
            }
            // get param data from path query
            data = pathQuery[key.name];
            if (data != null) {
              positionalArguments.add(data);
              continue;
            }
            // get param data from json body
            data = body[key.name];
            if (data != null) {
              positionalArguments.add(data);
              continue;
            }
            if (!key.isOptional) {
              return {
                #status: 500,
                "msg":
                    "The request content type is null but there is a not nullable method param "
                        "`${key.name}` of type `${key.type}`",
              };
            }
          }
        }
      } else {
        for (MethodParam key in params) {
          // get param data from path params
          var data = pathParams[key.name];
          if (data != null) {
            positionalArguments.add(data);
            continue;
          }
          // get param data from path query
          data = pathQuery[key.name];
          if (data != null) {
            try {
              if (key.type == String) positionalArguments.add(data);
              if (key.type == int) positionalArguments.add(int.parse(data));
              if (key.type == double) {
                positionalArguments.add(double.parse(data));
              }
            } catch (e) {
              print(e.toString());
              return {#status: 500, "error": e.toString()};
            }
            continue;
          }
        }
      }
    }
    // calling method
    try {
      var res = libraryMirror.invoke(method, positionalArguments);
      if (res.reflectee is Future) return await res.reflectee;
      return res.reflectee;
    } catch (e) {
      print(e.toString());
      return {#status: 500, "error": e.toString()};
    }
  }
}
