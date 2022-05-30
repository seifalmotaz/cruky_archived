library cruky.handlers.schema;

import 'package:cruky/src/handlers/routes/abstract.dart';
import 'package:cruky/src/request/req.dart';
import 'package:cruky/src/scanner/scanner.dart';

import 'parser.dart';

class SchemaHandler extends RouteHandler {
  final Function handler;
  final SchemaType schema;
  SchemaHandler(
    PipelineMock mock, {
    required this.handler,
    required this.schema,
    List<String> accepted = const [],
  }) : super(mock, accepted);

  @override
  Future handle(Request req) async {
    Object obj = await schema.get(req);
    return await handler(req, obj);
  }
}
