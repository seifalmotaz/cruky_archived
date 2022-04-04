import 'package:cruky/cruky.dart';

import 'routes/crud.dart';

class TodoApp extends AppMaterial {
  @override
  String get prefix => '/todo/';

  @override
  List get middlewares => [];

  @override
  List get routes => [
        list,
        get,
        create,
        delete,
      ];
}
