import 'dart:async';

import 'package:cruky/src/request/request.dart';

typedef MethodMW<RespType> = FutureOr<RespType> Function(ReqCTX);
