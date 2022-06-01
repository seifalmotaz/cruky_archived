import 'dart:convert';
import 'dart:io';

import 'package:cruky/src/common/ansicolor.dart';
import 'package:cruky/src/common/mimetypes.dart';
import 'package:cruky/src/constants.dart';
import 'package:cruky/src/errors/exp_res.dart';
import 'package:cruky/src/request/req.dart';

abstract class Response {
  final int status;
  const Response(this.status);
  Future<void> write(Request req) async {
    req.res.close();
    if (printLogs) {
      print("${info('INFO:')} [${DateTime.now().toIso8601String()}] "
          "HTTP/${req.native.protocolVersion} "
          "${req.method} ${ok(req.uri.path)} ${req.res.statusCode}");
    }
  }

  ExceptionResponse exp() => ExceptionResponse(this);
}

class Text extends Response {
  final String text;
  const Text(this.text, [super.status = 200]);

  @override
  Future<void> write(Request req) async {
    req.res.statusCode = status;
    req.res.headers.contentType = ContentType.text;
    req.res.write(text);
    await super.write(req);
  }
}

class Json extends Response {
  final Object body;

  const Json(this.body, [super.status = 200])
      : assert(body is Map || body is List);

  @override
  Future<void> write(Request req) async {
    req.res.statusCode = status;
    req.res.headers.contentType = ContentType.json;
    req.res.write(jsonEncode(body));
    await super.write(req);
  }
}

class FileStream extends Response {
  final String uri;
  const FileStream(this.uri) : super(200);

  @override
  Future<void> write(Request req) async {
    File file = File(uri);
    String? mimetype = MimeTypes.ofFile(file);
    if (mimetype != null) {
      List list = mimetype.split('/');
      req.res.headers.contentType = ContentType(list.first, list.last);
    } else {
      req.res.headers.contentType = ContentType.binary;
    }
    await req.res
        .addStream(file.openRead())
        .then((value) async => await super.write(req))
        .onError((error, stackTrace) {
      Text("Error when sending file data", 500).write(req);
    });
  }
}
