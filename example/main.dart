import 'package:cruky/cruky.dart';
import 'package:cruky/handlers.dart';

void main() => runApp(MyApp(), debug: true);

class MyApp extends ServerApp {
  @override
  String get address => '0.0.0.0';

  @override
  int get port => 80;

  @override
  int get isolates => 5;

  @override
  int get cores => 2;

  @override
  List get routes => [
        exampleWithGETRequest,
        getData,
        method,
        ExampleApp(),
      ];

  @override
  List get middlewares => [middlewareExample];

  @direct
  @Route.get('/method')
  method(ReqCTX req) {
    return Text("It's working");
  }
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

class ExampleApp extends AppMaterial {
  @override
  String get prefix => '/example';

  @override
  List get routes => [
        getExample,
      ];

  /// this is route method with path '/example/get/',
  ///
  /// And it will accept just json content-type request because of
  /// `JsonCTX` [req] type
  @Route.get('/get')
  getExample(JsonCTX req) {
    return Text('Nested apps');
  }
}
