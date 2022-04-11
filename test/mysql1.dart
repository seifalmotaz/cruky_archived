import 'package:cruky/cruky.dart';
import 'package:cruky/db/mysql1.dart';

void main() => runApp(MyApp());

class MyApp extends ServerApp {
  @override
  List get routes => [
        getData,
      ];

  @override
  List<PluginApp> get plugins => [
        Mysql1Plugin(
          user: 'root',
          password: 'root',
          db: 'labdesk',
        ),
      ];
}

@Route.get('/')
getData(ReqCTX req) {
  print(mysql1);
  return Text('Working');
}
