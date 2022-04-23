import 'package:cruky/cruky.dart';

void main() => runApp(MyApp());

class MyApp extends ServerApp {
  @override
  List get routes => [
        example,
        ExampleApp(),
      ];
}

@Route.get('/:id(string)', pipeline: [middlewareExample])
example(Request req) {
  return req.path.get('id');
}

@UsePre()
middlewareExample(Request req) {
  if (req.headerValue('Token') == null) {
    return Text('Not Auth', 401);
  } else {
    req.parser[#token] = req.headerValue('Token')!;
  }
}

class ExampleApp extends AppMaterial {
  @override
  String get prefix => '/example';

  @override
  List get routes => [
        getExample,
      ];

  @Route.get('/get')
  getExample(Request req) {
    return Text('Nested apps');
  }
}
