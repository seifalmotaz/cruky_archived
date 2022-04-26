import 'package:cruky/src/core/res.dart';

abstract class StatusCodes {
  Response e404([dynamic msg]);
  Response e405([dynamic msg]);
  Response e500([dynamic msg]);
  Response e422([dynamic msg]);
  Response e406([dynamic msg]);
}

class TextStatusCodes extends StatusCodes {
  @override
  Response e404([dynamic msg]) => Text(msg ?? 'Page not found', 404);

  @override
  Response e405([dynamic msg]) => Text(msg ?? 'Method not allowed', 405);

  @override
  Response e500([dynamic msg]) => Text(msg ?? 'Server error', 500);

  @override
  Response e422([dynamic msg]) => Text(msg, 422);

  @override
  Response e406([dynamic msg]) => Text(msg ?? 'Not Acceptable', 406);
}
