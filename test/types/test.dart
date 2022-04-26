import 'package:cruky/cruky.dart';

void main() => runApp(MyApp());

class MyApp extends ServerApp {
  @override
  List get routes => [
        example,
        exampleList,
        exampleString,
      ];
}

@Route.get('/')
Map example(Map req) {
  return req;
}

@Route.get('/list')
List exampleList(List req) {
  return req;
}

@Route.get('/text')
String exampleString(String req) {
  return req;
}
