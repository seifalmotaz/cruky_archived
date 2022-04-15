import 'package:cruky/cruky.dart';
import 'package:cruky/src/handlers/indirect/parser.dart';

void main() => runApp(MyApp(), debug: true);

class MyApp extends ServerApp {
  @override
  List get routes => [
        testQuery,
        testJson,
        testJson2,
        testJson3,
        testForm,
      ];
}

@Route.get('/')
testQuery(num w) {
  return Text('ok $w');
}

@Route.get('/f')
testForm(@cform List w) {
  return Text('ok $w');
}

@Route.get('/j')
testJson(Map data) {
  return Text('ok $data');
}

@Route.get('/jr')
testJson2(Map data, List da) {
  return Text('ok $data, $da');
}

@Route.get('/jrl')
testJson3(List data) {
  return Text('ok $data');
}
