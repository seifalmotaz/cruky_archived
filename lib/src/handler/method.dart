part of cruky.handlers;

/// get the fields from multi form fields
RegExp _matchName = RegExp('name=["|\'](.+)["|\']');
RegExp _matchFileName = RegExp('filename=["|\'](.+)["|\']');

class MethodHandler {
  final String method;
  final PathRegex path;
  final Type requestType;
  final Function handler;

  MethodHandler({
    required this.path,
    required this.method,
    required this.handler,
    required this.requestType,
  });

  bool match(String _path, String _method) {
    if (_method != method) return false;
    return path.match(_path);
  }

  /// handle request
  handle(HttpRequest request) async {
    try {
      if (requestType == JsonRequest) {
        return await jsonRequestHandler(request);
      } else if (requestType == FormRequest) {
        return await formRequestHandler(request);
      } else if (requestType == iFormRequest) {
        return await iFormRequestHandler(request);
      }
      return await simpleRequestHandler(request);
    } catch (e) {
      return {
        #status: 500,
        "msg": e.toString(),
      };
    }
  }

  simpleRequestHandler(HttpRequest request) async =>
      await handler(SimpleRequest(
        path: request.uri,
        query: request.uri.queryParametersAll,
        parameters: path.parseParams(request.uri.path),
      ));

  /// handle request if it's json body
  jsonRequestHandler(HttpRequest request) async {
    String string = await utf8.decodeStream(request);
    Map body = string.isEmpty ? {} : jsonDecode(string);
    JsonRequest req = JsonRequest(
      body: body,
      path: request.uri,
      query: request.uri.queryParametersAll,
      parameters: path.parseParams(request.uri.path),
    );
    return await handler(req);
  }

  /// get request bytes
  Future<Uint8List> _getBytes(HttpRequest request) {
    return request
        .fold<BytesBuilder>(BytesBuilder(copy: false), (a, b) => a..add(b))
        .then((b) => b.takeBytes());
  }

  /// handle form request
  formRequestHandler(HttpRequest request) async {
    var bytes = await _getBytes(request);

    Map<String, String> body =
        Uri.splitQueryString(String.fromCharCodes(bytes));
    FormRequest req = FormRequest(
      parameters: path.parseParams(request.uri.path),
      path: request.uri,
      query: request.uri.queryParametersAll,
      form: body,
    );

    return await handler(req);
  }

  /// handle multipart form request
  iFormRequestHandler(HttpRequest request) async {
    final Map<String, String> formFields = {};
    final Map<String, FilePart> formFiles = {};
    Stream<Uint8List> stream;

    var bytes = await _getBytes(request);
    var ctrl = StreamController<Uint8List>()
      ..add(bytes)
      ..close();
    stream = ctrl.stream;

    var parts = MimeMultipartTransformer(
            request.headers.contentType!.parameters['boundary']!)
        .bind(stream);

    await for (MimeMultipart part in parts) {
      String headers = part.headers['content-disposition']!;

      /// split headers fields
      List<String> headersFields = headers.split(';');

      /// get the name of form field
      String field = headersFields.firstWhere((e) => _matchName.hasMatch(e));
      RegExpMatch? fieldNameMatch = _matchName.firstMatch(field);

      /// check if the field name exist
      {
        if (fieldNameMatch == null) {
          return {
            #status: 500,
            "msg": "Cannot find the header name field for the request",
          };
        }

        if (fieldNameMatch[1] == null) {
          return {
            #status: 500,
            "msg": "the form field name is empty please "
                "try to put a name for the field",
          };
        }
      }

      String name = fieldNameMatch[1]!;

      /// check if this part is field or file
      if (!headers.contains('filename=')) {
        /// handle if if it's a field
        formFields[name] = await utf8.decodeStream(part);
        continue;
      }

      /// handle if it's file
      /// get file name from headers
      field = headersFields.firstWhere((e) => _matchFileName.hasMatch(e));
      RegExpMatch? fileNameMatch = _matchFileName.firstMatch(headers);

      /// check if the file name exist
      {
        if (fileNameMatch == null) {
          return {
            #status: 500,
            "msg": "Cannot find the header name field for the request",
          };
        }

        if (fileNameMatch[1] == null) {
          return {
            #status: 500,
            "msg": "the form field name is empty please "
                "try to put a name for the field",
          };
        }
      }

      String filename = fileNameMatch[1]!;

      /// add the file to formFiles as stream
      Stream<List<int>> streamBytes = part.asBroadcastStream();
      formFiles[name] = FilePart(name, filename, streamBytes);
    }

    /// call the method handler
    iFormRequest req = iFormRequest(
      form: formFields,
      files: formFiles,
      path: request.uri,
      query: request.uri.queryParametersAll,
      parameters: path.parseParams(request.uri.path),
    );

    return await handler(req);
  }
}
