part of cruky.handlers;

class DirectHandler extends MethodHandler {
  final Function handler;

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
  handle(HttpRequest request, ResCTX resCTX) async {
    late SimpleReq req;

    switch (requestType) {
      case JsonReq:
        req = await BodyCompiler.json(request, path);
        break;
      case FormReq:
        req = await BodyCompiler.form(request, path);
        break;
      case iFormReq:
        req = await BodyCompiler.iForm(request, path);
        break;
      default:
        req = BodyCompiler.simple(request, path);
    }

    return await handler(req, resCTX);
  }
}
