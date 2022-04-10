import 'package:cruky/handlers.dart';
import 'package:cruky/src/interfaces/app_material/app_material.dart';

/// This is the main entry point for the server.
///
/// Here we define the settings of server like (address, port, isolates, cores)
///
/// it's abstract of AppMatrial but with extra options
abstract class ServerApp extends AppMaterial {
  /// the server listen address
  String get address => '127.0.0.1';

  /// server port
  int get port => 5000;

  /// number of server listeners in the single isolate
  int get cores => 1;

  /// number of isolate that will run
  int get isolates => 5;

  /// types of handlers you can add custom type here
  List<HandlerType> get handlerTypes => [];

  /// define if you want to handle every request in different isolate.
  ///
  /// the default is false.
  bool get useReqIsolator => false;
}
