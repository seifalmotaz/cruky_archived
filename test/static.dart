import 'package:cruky/cruky.dart';
import 'package:cruky/static.dart';

void main() => runApp(MyApp());

class MyApp extends ServerApp {
  @override
  List get routes => [static('./api', 'api')];
}
