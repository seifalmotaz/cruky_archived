import 'package:cruky/cruky.dart';

void main() => runApp(
      MyApp(),
      isolates: 2,
      listeners: 2,
    );

class MyApp extends ServerApp {
  @override
  List get routes => [
        example,
        ExampleApp(),
      ];
}

@Route.get('/:id(int)', pipeline: [middlewareExample])
example(Request req) {
  return req.path['id'].toString();
}

@UsePre()
middlewareExample(Request req) {
  if (req.headerValue('Authorization') == null) {
    throw Text('Not Auth', 401);
  } else {
    req.parser[#token] = req.headerValue('Authorization')!;
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
