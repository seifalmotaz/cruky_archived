part of cruky.handlers;

class MethodHandler extends RequestHandler {
  Symbol lib;
  Symbol method;
  List<MethodParam> params;
  MethodHandler(
    this.lib,
    this.method,
    this.params,
    List<MiddlewareMap> middlewares,
  ) : super(middlewares);

  @override
  dynamic handler({
    required HttpRequest req,
    required Map<String, dynamic> pathParams,
    required Map<String, dynamic> pathQuery,
  }) async {
    Map<String, dynamic> allParams = {...pathParams, ...pathQuery};
    final List positionalArguments = [];

    if (params.isNotEmpty) {
      if (req.headers.contentType != null) {
        if (req.headers.contentType?.mimeType == ReqHeader.jsonType) {
          Map? json = await _jsonParamsHandler(
            req: req,
            positionalArguments: positionalArguments,
            allParams: allParams,
          );
          if (json != null) return json;
        }
      } else {
        Map? json = await _paramsHandler(
          req: req,
          positionalArguments: positionalArguments,
          allParams: allParams,
        );
        if (json != null) return json;
      }
    }

    // calling method
    try {
      LibraryMirror libraryMirror = currentMirrorSystem().findLibrary(lib);
      var res = libraryMirror.invoke(method, positionalArguments);
      if (res.reflectee is Future) return await res.reflectee;
      return res.reflectee;
    } catch (e) {
      print(e.toString());
      return {#status: 500, "error": e.toString()};
    }
  }

  Future<Map?> _paramsHandler({
    required HttpRequest req,
    required List positionalArguments,
    required Map<String, dynamic> allParams,
  }) async {
    // call middlewares
    Map? result = await middlewaresParamsParser(allParams);
    if (result != null) return result;
    for (MethodParam key in params) {
      // get param data from path params
      var data = allParams[key.name];
      if (data != null) {
        positionalArguments.add(data);
        continue;
      }
      // get param data from path query
      data = allParams[key.name];
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
    return null;
  }

  Future<Map?> _jsonParamsHandler({
    required HttpRequest req,
    required List positionalArguments,
    required Map<String, dynamic> allParams,
  }) async {
    String stringBody = await utf8.decodeStream(req);
    if (stringBody.isEmpty) {
      return {
        #status: 500,
        "msg": "json body is not defined",
      };
    }
    Map<String, dynamic> body = jsonDecode(stringBody);
    allParams.addAll(body);
    // call middlewares
    Map? result = await middlewaresParamsParser(allParams);
    if (result != null) return result;
    // get ready for calling the main method
    for (MethodParam key in params) {
      // get param data from path params
      var data = allParams[key.name];
      if (data != null) {
        positionalArguments.add(data);
        continue;
      }
      // get param data from path query
      data = allParams[key.name];
      if (data != null) {
        positionalArguments.add(data);
        continue;
      }
      // get param data from json body
      data = allParams[key.name];
      if (data != null) {
        positionalArguments.add(data);
        continue;
      }
      // get param data from middleware parser
      data = allParams[key.name];
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

    return null;
  }

  Future<Map?> middlewaresParamsParser(Map<String, dynamic> allParams) async {
    // param parser nested function for middleware params
    middlewareParamParser(
      List<MethodParam> _params,
      List _positionalArguments,
    ) {
      for (MethodParam key in _params) {
        // get param data from path params
        var data = allParams[key.name];
        if (data != null) {
          _positionalArguments.add(data);
          continue;
        }
        // get param data from path query
        data = allParams[key.name];
        if (data != null) {
          _positionalArguments.add(data);
          continue;
        }
        // get param data from json body
        data = allParams[key.name];
        if (data != null) {
          _positionalArguments.add(data);
          continue;
        }
        if (key.isOptional) {
          _positionalArguments.add(null);
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

    // get ready for calling middleware functions
    Map<String, dynamic> middlewaresParser = {};
    for (MiddlewareMap middleware in middlewares) {
      List _positionalArguments = [];
      middlewareParamParser(middleware.params, _positionalArguments);
      ClassMirror c = reflectClass(middleware.type);
      InstanceMirror mirror = c.newInstance(Symbol.empty, _positionalArguments);
      InstanceMirror result = mirror.invoke(#main, []);
      Map data = await result.reflectee;
      if (data.containsKey(#error)) {
        data.remove(#error);
        return data;
      }
      data = Map<String, dynamic>.from(data);
      middlewaresParser.addAll(data as Map<String, dynamic>);
    }
    allParams.addAll(middlewaresParser);
    return null;
  }
}
