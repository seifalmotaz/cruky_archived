part of cruky.server;

String getDate(DateTime date) {
  String string = '';
  string += "${date.year}/";
  string += "${date.month}/";
  string += "${date.day}";
  string += ' ';
  string += "${date.hour}:";
  string += "${date.minute}:";
  string += "${date.second}";
  return string;
}

extension Handlers on CrukyServer {
  Future<void> _writeResponse(HttpRequest req, data, DateTime date) async {
    if (data is Response) {
      try {
        data.writeResponse(req);
      } catch (e, stack) {
        print(e);
        print(stack);
      }
    }
    if (data is Map || data is List) {
      Json(data).writeResponse(req);
    }
    if (data is String) {
      Text(data).writeResponse(req);
    }
    await req.response.close();
    switch (req.response.statusCode) {
      case 404:
        print("\x1B[252m${getDate(date)}\x1B[0m "
            "\x1B[96m${req.method}: ${req.uri.path}\x1B[0m"
            "\x1B[33m ${req.response.headers.contentType!.mimeType}: ${req.response.statusCode}\x1B[0m");
        break;
      case 500:
        print("\x1B[252m${getDate(date)}\x1B[0m "
            "\x1B[96m${req.method}: ${req.uri.path}\x1B[0m"
            "\x1B[31m ${req.response.headers.contentType!.mimeType}: ${req.response.statusCode}\x1B[0m");
        break;
      default:
        print("\x1B[252m${getDate(date)}\x1B[0m "
            "\x1B[96m${req.method}: ${req.uri.path}\x1B[0m"
            "\x1B[34m ${req.response.headers.contentType!.mimeType}: ${req.response.statusCode}\x1B[0m");
    }
  }

  _handle(HttpRequest req) async {
    DateTime date = DateTime.now();
    BlankRoute? matched = _matchReq(req);
    if (matched == null) {
      await _writeResponse(req, Json({'msg': 'not found'}, 404), date);
      return;
    }
    try {
      if ((req.headers.contentType == null && matched.accepted.isNotEmpty) ||
          (matched.accepted.isNotEmpty &&
              !matched.accepted.contains(req.headers.contentType!.mimeType))) {
        final res = Json({'msg': 'Not acceptable content-type'}, 415);
        await _writeResponse(req, res, date);
        return;
      }
      final result = await matched(req);
      await _writeResponse(req, result, date);
    } catch (e, stack) {
      if (e is ExceptionRes) {
        await _writeResponse(req, e, date);
        if (e.error != null) {
          print(e.error!.msg);
          print(e.error!.stackTrace);
        }
      } else {
        print(e);
        print(stack);
      }
    }
  }
}
