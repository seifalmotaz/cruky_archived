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
    if (requestType == JsonReq) {
      return await handler(await BodyCompiler.json(request, path));
    } else if (requestType == FormReq) {
      return await handler(await BodyCompiler.form(request, path));
    } else if (requestType == iFormReq) {
      return await BodyCompiler.iForm(request, path);
    }
    return await handler(BodyCompiler.simple(request, path));
  }
}
