library cruky.handlers.json;

import 'dart:mirrors';

import 'package:cruky/handlers.dart';
import 'package:cruky/src/common/mimetypes.dart';
import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/helpers/liberror.dart';
import 'package:cruky/src/helpers/path_parser.dart';
import 'package:cruky/src/interfaces/handler.dart';
import 'package:cruky/src/request/request.dart';

final formHandler = HandlerType<_FormHandler>(
  parser: FormRoute.parse,
  annotiationType: formType,
);

/// json request format
///
/// this handler will make your route just acceptjson content-type
class FormCTX {
  /// json decoded data
  final Map data;

  /// the main request
  final ReqCTX req;

  /// json request format
  FormCTX(this.data, this.req);

  /// get the data with `req['dataKey']`
  operator [](Object i) => data[i];
}

/// json handler prototype
typedef _FormHandler = Function(FormCTX);

/// json route annotiation
const form = _Form();

/// json route public type
const Type formType = _Form;

/// direct route annotiation
class _Form extends HandlerInfo {
  /// direct route annotiation
  const _Form();
}

class FormRoute extends BlankRoute {
  final _FormHandler handler;

  FormRoute({
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
    var data = await req.form();
    return await handler(FormCTX(data, req));
  }

  static Future<BlankRoute> parse(Function handler, BlankRoute route) async {
    try {
      handler as _FormHandler;
    } on TypeError {
      ClosureMirror mirror = reflect(handler) as ClosureMirror;
      var sourceLocation = mirror.function.location!;
      throw LibError(
        '\x1B[31mMethod of path "${route.path.path + '/'}" is not subtype of $_FormHandler\n'
            'Try to add annotiation to specify the method handler type.\x1B[0m',
        "${sourceLocation.sourceUri.toFilePath()}:${sourceLocation.line}:${sourceLocation.column}",
      );
    }
    return FormRoute(
      handler: handler,
      path: route.path,
      methods: route.methods,
      beforeMW: route.beforeMW,
      afterMW: route.afterMW,
      accepted: [MimeTypes.urlEncodedForm],
    );
  }
}