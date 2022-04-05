import 'package:cruky/cruky.dart';

void main() => run<MyApp>();

class MyApp extends ServerApp {
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

@BeforeMW()
middlewareExample(ReqCTX req) {
  if (req.headerValue('Token') == null) {
    return Text('Not Auth', 401);
  }
}
