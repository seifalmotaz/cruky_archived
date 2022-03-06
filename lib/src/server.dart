library server;

import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:cruco/src/linkee/linkee.dart';

import 'helpers/typedef.dart';
import 'interfaces/request.dart';
import 'middleware.dart';

part './router.dart';

class Cruco extends Router {
  String host;
  int port;
  Cruco([this.host = '127.0.0.1', this.port = 5678]);

  late HttpServer _httpServer;

  serve([String? _host, int? _port]) async {
    _httpServer = await HttpServer.bind(_host ?? host, _port ?? port);

    print('Start server at $host:$port');
    await for (HttpRequest request in _httpServer) {
      // var bodyHandler = request.transform(HttpBodyHandler());

      // get the request handler
      Linkee linkee = _match(request.uri.path, request.method);
      // check the hendler type
      // direct method handler
      if (linkee is LinkeeMethod) {
        await methodHandeler(linkee, request);
        // close response and goto next request
        request.response.close();
        continue;
      }
    }
  }

  Future methodHandeler(LinkeeMethod linkee, HttpRequest request) async {
    late Map resBody;
    CrucoRequest req = CrucoRequest(
      request.headers.contentType!,
      jsonDecode(await utf8.decodeStream(request)),
    );
    if (linkee.isAsync) {
      resBody = await linkee.on(req);
    } else {
      resBody = linkee.on(req);
    }

    if (resBody is MapResponse) {
      // set basic response info (headers, statusCode, ..etc)
      request.response.headers.set("Content-type", "application/json");
      request.response.statusCode = resBody[#status] ?? 200;
      // set the main response body
      request.response.write(jsonEncode(resBody[#body]));
    } else {
      // set the main response body
      resBody.removeWhere((key, value) => key is Symbol);
      request.response.write(jsonEncode(resBody));
    }
  }
}
