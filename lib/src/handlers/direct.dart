library cruky.handlers.direct;

import 'dart:mirrors';
import 'dart:async';

import 'package:cruky/handlers.dart';
import 'package:cruky/src/common/prototypes.dart';
import 'package:cruky/src/helpers/liberror.dart';
import 'package:cruky/src/helpers/path_parser.dart';
import 'package:cruky/src/interfaces/handler.dart';
import 'package:cruky/src/request/request.dart';

/// prototype function
typedef DirectHandler<RespType> = FutureOr<RespType> Function(ReqCTX);

final directHandler = HandlerType<DirectHandler>(
  parser: DirectRoute.parse,
  annotiationType: directType,
);

/// direct route annotiation
const direct = _Direct();
const Type directType = _Direct;

/// direct route annotiation
class _Direct extends HandlerInfo {
  /// direct route annotiation
  const _Direct();
}

class DirectRoute extends BlankRoute {
  final DirectHandler handler;

  DirectRoute({
    required this.handler,
    required PathParser path,
    required List<String> methods,
    required List<MethodMW> beforeMW,
    required List<MethodMW> afterMW,
    required List<String> accepted,
  }) : super(
          accepted: accepted,
          methods: methods,
          path: path,
          beforeMW: beforeMW,
          afterMW: afterMW,
        );

  @override
  Future handle(ReqCTX req) async => await handler(req);

  static Future<BlankRoute> parse(Function handler, BlankRoute route) async {
    try {
      handler as DirectHandler;
    } on TypeError {
      ClosureMirror mirror = reflect(handler) as ClosureMirror;
      var sourceLocation = mirror.function.location!;
      throw LibError(
        '\x1B[31mMethod of path "${route.path.path + '/'}" is not subtype of $DirectHandler\n'
            'Try to add annotiation to specify the method handler type.\x1B[0m',
        "${sourceLocation.sourceUri.toFilePath()}:${sourceLocation.line}:${sourceLocation.column}",
      );
    }
    return DirectRoute(
      handler: handler,
      path: route.path,
      methods: route.methods,
      beforeMW: route.beforeMW,
      afterMW: route.afterMW,
      accepted: route.accepted,
    );
  }
}
