import 'package:cruky/cruky.dart';

void main() => runApp(MyApp());

class MyApp extends ServerApp {
  @override
  Map<String, String> get statics => {
        "./docs": "/api/docs",
      };
}
