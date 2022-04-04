import 'dart:async';

import 'package:cruky/src/request/request.dart';

typedef DirectHandler<RespType> = FutureOr<RespType> Function(ReqCTX);
typedef InDirectHandler = Function;
