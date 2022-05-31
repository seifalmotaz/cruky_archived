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
String example(Request req) {
  return req.pathParams['id'];
}

@UsePre()
middlewareExample(Request req) {
  if (req.headerValue('Authorization') == null) {
    return Text('Not Auth', 401);
  } else {
    req.parser[#token] = req.headerValue('Authorization')!;
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
