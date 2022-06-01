import 'package:cruky/cruky.dart';

/// my data is here
/// for sec token
void main() => runApp(MyApp(), isolates: 2);

class MyApp extends ServerApp {
  @override
  Map<String, String> get statics => {"./docs": "/docs"};

  @override
  List get routes => [
        example,
        exampleForm,
        ExampleApp(),
      ];

  @override
  ServerBind init() {
    return ServerBind(port: 8080);
  }
}

@Route.get('/:id(double)', pipeline: [middlewareExample])
example(Request req) {
  return req.pathParams['id'].toString();
}

@Route.post('/form')
exampleForm(Request req) async {
  var form = await req.form();
  return form['data'];
}

@UsePre()
middlewareExample(Request req) {
  if (req.headers.value('Authorization') == null) {
    throw Text('Not Auth', 401).exp();
  } else {
    req.parser[#token] = req.headers.value('Authorization')!;
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
