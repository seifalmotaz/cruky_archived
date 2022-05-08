import 'package:cruky/cruky.dart';

void main() => runApp(MyApp());

class MyApp extends ServerApp {
  @override
  List get routes => [staatic, static];
}

@Route.get('/.+')
static(Request req) {
  return req.uri.path;
}

@Route.get('/example/.+')
staatic(Request req) {
  return req.uri.path + ' sec';
}
