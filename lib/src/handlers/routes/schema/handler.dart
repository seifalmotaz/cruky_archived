library cruky.handlers.schema;

import 'package:cruky/src/errors/exp_res.dart';
import 'package:cruky/src/handlers/routes/abstract.dart';
import 'package:cruky/src/request/req.dart';

class SchemaHandler extends RouteHandler {
  final Function handler;
  SchemaHandler(mock, accepted, this.handler)
      : super(mock, acceptedContentType: accepted);

  @override
  Future handle(Request req) async {
    var other = await req.json();
    try {
      return await handler(other);
    } on TypeError {
      return ERes.e406();
    }
  }
}
