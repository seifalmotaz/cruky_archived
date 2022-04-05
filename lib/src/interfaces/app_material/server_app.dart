import 'package:cruky/src/interfaces/app_material/app_material.dart';

abstract class ServerApp extends AppMaterial {
  /// the server listen address
  String get address => '127.0.0.1';

  /// server port
  int get port => 5000;

  /// number of server listeners in the single isolate
  int get cores => 1;

  /// number of isolate that will run
  int get isolates => 5;
}
