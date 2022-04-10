// ignore_for_file: camel_case_types

library cruky.handlers.json;

import 'dart:mirrors';

import 'package:cruky/handlers.dart';
import 'package:cruky/src/common/mimetypes.dart';
import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/helpers/liberror.dart';
import 'package:cruky/src/helpers/path_parser.dart';
import 'package:cruky/src/interfaces/handler.dart';
import 'package:cruky/src/request/request.dart';

final iFormHandler = HandlerType<_iFormHandler>(
  parser: IFormRoute.parse,
  annotiationType: iFormType,
);

/// json request format
///
/// this handler will make your route just acceptjson content-type
class iFormCTX extends iFormData {
  /// the main request
  final ReqCTX req;

  /// json request format
  iFormCTX(iFormData data, this.req) : super(data.formFields, data.formFiles);
}

/// json handler prototype
typedef _iFormHandler = Function(iFormCTX);

/// json route annotiation
const iForm = _iForm();

/// json route public type
const Type iFormType = _iForm;

/// direct route annotiation
class _iForm extends HandlerInfo {
  /// direct route annotiation
  const _iForm();
}

class IFormRoute extends BlankRoute {
  final _iFormHandler handler;

  IFormRoute({
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
    final iFormData data = await req.iForm();
    return await handler(iFormCTX(data, req));
  }

  static Future<BlankRoute> parse(Function handler, BlankRoute route) async {
    try {
      handler as _iFormHandler;
    } on TypeError {
      ClosureMirror mirror = reflect(handler) as ClosureMirror;
      var sourceLocation = mirror.function.location!;
      throw LibError(
        '\x1B[31mMethod of path "${route.path.path + '/'}" is not subtype of $_iFormHandler\n'
            'Try to add annotiation to specify the method handler type.\x1B[0m',
        "${sourceLocation.sourceUri.toFilePath()}:${sourceLocation.line}:${sourceLocation.column}",
      );
    }
    return IFormRoute(
      handler: handler,
      path: route.path,
      methods: route.methods,
      beforeMW: route.beforeMW,
      afterMW: route.afterMW,
      accepted: [MimeTypes.multipartForm],
    );
  }
}
