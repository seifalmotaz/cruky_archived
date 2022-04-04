import 'package:cruky/cruky.dart';

void main() => run(MyApp());

class MyApp extends AppMaterial {
  @override
  List get routes => [
        exampleWithGETRequest,
      ];

  @override
  List get middlewares => [middlewareExample];
}

@Route.get('/')
exampleWithGETRequest(ReqCTX req) {
  return Json({});
}

@Route.get('/')
middlewareExample(ReqCTX req) {
  if (req.headerValue('Token') == null) {
    return Text('Not Auth', 401);
  }
}
