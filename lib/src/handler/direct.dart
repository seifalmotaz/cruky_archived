part of cruky.handlers;

class DirectHandler extends MethodHandler {
  final dynamic Function(dynamic req) handler;

  DirectHandler({
    required path,
    required method,
    required this.handler,
    required requestType,
  }) : super(
          method: method,
          path: path,
          requestType: requestType,
        );

  /// handle request
  @override
  handle(HttpRequest request) async {
    if (requestType == JsonRequest) {
      return await jsonRequestHandler(request);
    } else if (requestType == FormRequest) {
      return await formRequestHandler(request);
    } else if (requestType == iFormRequest) {
      return await iFormRequestHandler(request);
    }
    return await simpleRequestHandler(request);
  }

  /// handle any body
  simpleRequestHandler(HttpRequest request) async =>
      await handler(BodyCompiler.simple(request, path));

  /// handle request if it's json body
  jsonRequestHandler(HttpRequest request) async =>
      await handler(await BodyCompiler.json(request, path));

  /// handle form request
  formRequestHandler(HttpRequest request) async =>
      await handler(await BodyCompiler.form(request, path));

  /// handle multipart form request
  iFormRequestHandler(HttpRequest request) async =>
      await BodyCompiler.iForm(request, path);
}
