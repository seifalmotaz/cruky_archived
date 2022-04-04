import 'package:cruky/cruky.dart';

import 'crud/routes/crud.dart';

void main() => run(MyApp());

class MyApp extends AppMaterial {
  @override
  String get prefix => '/';

  @override
  List get middlewares => [
        mwExample,
        mwExampleAfter,
      ];

  @override
  List get routes => [
        example,
        use.lib(list),
      ];
}

@Route.get('/')
example(ReqCTX req) {
  return Json({'example': 'route'});
}

@MiddlewareBefore()
mwExample(ReqCTX req) {
  print('before');
}

@MiddlewareAfter()
mwExampleAfter(ReqCTX req) {
  print('after');
}
