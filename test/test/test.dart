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
    throw Text('Not Auth', 401);
  } else {
    req.parser[#token] = req.headerValue('Token')!;
  }
}

class ExampleApp extends InApp {
  @override
  String get prefix => '/example';

  @Route.get('/get')
  getExample(Request req) {
    return Text('Nested apps');
  }
}
