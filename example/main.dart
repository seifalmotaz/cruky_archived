import 'package:cruky/cruky.dart';

void main() => run<MyApp>();

class MyApp extends ServerApp {
  @override
  List get routes => [
        exampleWithGETRequest,
        getData,
      ];

  @override
  List get middlewares => [middlewareExample];
}

@Route.get('/')
exampleWithGETRequest(ReqCTX req) {
  return Json({'token': req.data['token']});
}

@Route.get('/:id(int)')
getData(ReqCTX req) {
  return Json({'id': req['id']});
}

@BeforeMW()
middlewareExample(ReqCTX req) {
  if (req.headerValue('Token') == null) {
    return Text('Not Auth', 401);
  } else {
    req.data['token'] = req.headerValue('Token')!;
  }
}
