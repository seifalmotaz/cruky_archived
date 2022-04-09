library cruky.handlers.json;

import 'dart:mirrors';

import 'package:cruky/handlers.dart';
import 'package:cruky/src/common/mimetypes.dart';
import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/helpers/liberror.dart';
import 'package:cruky/src/helpers/path_parser.dart';
import 'package:cruky/src/interfaces/handler.dart';
import 'package:cruky/src/request/request.dart';

final jsonHandler = HandlerType<_JsonHandler>(
  parser: JsonRoute.parse,
  annotiationType: jsonType,
);

/// json request format
///
/// this handler will make your route just acceptjson content-type
class JsonCTX {
  /// json decoded data
  final Map data;

  /// the main request
  final ReqCTX req;

  /// json request format
  JsonCTX(this.data, this.req);

  /// get the data with `req['dataKey']`
  operator [](Object i) => data[i];
}

/// json handler prototype
typedef _JsonHandler = Function(JsonCTX);

/// json route annotiation
const json = _Json();

/// json route public type
const Type jsonType = _Json;

/// direct route annotiation
class _Json extends HandlerInfo {
  /// direct route annotiation
  const _Json();
}

class JsonRoute extends BlankRoute {
  final _JsonHandler handler;

  JsonRoute({
    required this.handler,
    required PathParser path,
    required List<String> methods,
    required List<MethodMW> beforeMW,
    required List<MethodMW> afterMW,
    required List accepted,
  }) : super(
          accepted: accepted,
          methods: methods,
          path: path,
          beforeMW: beforeMW,
          afterMW: afterMW,
        );

  @override
  Future handle(ReqCTX req) async {
    var data = await req.json();
    return await handler(JsonCTX(data, req));
  }

  static Future<BlankRoute> parse(Function handler, BlankRoute route) async {
    try {
      handler as _JsonHandler;
    } on TypeError {
      ClosureMirror mirror = reflect(handler) as ClosureMirror;
      var sourceLocation = mirror.function.location!;
      throw LibError(
        '\x1B[31mMethod of path "${route.path.path + '/'}" is not subtype of $_JsonHandler\n'
            'Try to add annotiation to specify the method handler type.\x1B[0m',
        "${sourceLocation.sourceUri.toFilePath()}:${sourceLocation.line}:${sourceLocation.column}",
      );
    }
    return JsonRoute(
      handler: handler,
      path: route.path,
      methods: route.methods,
      beforeMW: route.beforeMW,
      afterMW: route.afterMW,
      accepted: [MimeTypes.json],
    );
  }
}
