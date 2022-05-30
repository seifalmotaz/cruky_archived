library cruky.extentions;

import 'package:cruky/src/errors/exp_res.dart';

extension CrukyStringExtention on String {
  ExceptionResponse exp() => ExceptionResponse(this);
}

extension CrukyMapExtention on Map {
  ExceptionResponse exp() => ExceptionResponse(this);
}

extension CrukyListExtention on List {
  ExceptionResponse exp() => ExceptionResponse(this);
}
