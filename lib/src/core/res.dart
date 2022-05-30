import 'dart:convert';
import 'dart:io';

import 'package:cruky/src/common/ansicolor.dart';
import 'package:cruky/src/common/mimetypes.dart';
import 'package:cruky/src/errors/exp_res.dart';

abstract class Response {
  final int status;
  const Response(this.status);
  Future<void> write(HttpRequest req) async {
    req.response.statusCode = status;
    req.response.close();
    print("${info('INFO:')} HTTP/${req.protocolVersion} "
        "${req.method} ${ok(req.uri.path)} ${req.response.statusCode}");
  }

  ExceptionResponse exp() => ExceptionResponse(this);
}

class Text extends Response {
  final String text;

  const Text(this.text, [super.status = 200]);

  @override
  Future<void> write(HttpRequest req) async {
    req.response.headers.contentType = ContentType.text;
    req.response.write(text);
    super.write(req);
  }
}

class Json extends Response {
  final Object body;

  const Json(this.body, [super.status = 200])
      : assert(body is Map || body is List);

  @override
  Future<void> write(HttpRequest req) async {
    req.response.headers.contentType = ContentType.json;
    req.response.write(jsonEncode(body));
    super.write(req);
  }
}

class FileStream extends Response {
  final String uri;
  const FileStream(this.uri, [super.status = 200]);

  @override
  Future<void> write(HttpRequest req) async {
    File file = File(uri);
    String? mimetype = MimeTypes.ofFile(file);
    if (mimetype != null) {
      List list = mimetype.split('/');
      req.response.headers.contentType = ContentType(list.first, list.last);
    } else {
      req.response.headers.contentType = ContentType.binary;
    }
    await req.response
        .addStream(file.openRead())
        .then((value) => super.write(req))
        .onError((error, stackTrace) {
      Text("Error when sending file data", 500).write(req);
    });
  }
}
