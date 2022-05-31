import 'package:cruky/cruky.dart';

void main() => multiRun([MyApp(), My2App()], debug: false);

class MyApp extends ServerApp {
  @override
  String get name => 'MyApp';

  @override
  List get routes => [
        example,
        ExampleApp(),
      ];
}

class My2App extends ServerApp {
  @override
  String get name => 'My2App';

  @override
  List get routes => [
        example,
        ExampleApp(),
      ];
}

@Route.get('/:id(int)')
example(Request req) {
  return req.pathParams['id'].toString();
}

class ExampleApp extends InApp {
  @override
  String get prefix => '/example';

  @Route.get('/get')
  getExample(Request req) {
    return Text('Nested apps');
  }
}
