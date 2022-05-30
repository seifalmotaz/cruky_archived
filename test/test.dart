import 'package:cruky/cruky.dart';
import 'package:cruky/static.dart';

/// my data is here
/// for sec token
void main() => runApp(MyApp(), isolates: 2);

class MyApp extends ServerApp {
  @override
  List get routes => [
        example,
        ExampleApp(),
        static('./api', 'api'),
      ];

  @override
  ServerBind init() {
    return ServerBind(port: 8828);
  }
}

@Route.get('/:id(double)', pipeline: [middlewareExample])
example(Request req) {
  return req.path['id'].toString();
}

@UsePre()
middlewareExample(Request req) {
  if (req.headerValue('Authorization') == null) {
    throw Text('Not Auth', 401).exp();
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
