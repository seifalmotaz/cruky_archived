library cruky.server_app;

import 'package:cruky/handlers.dart';
import 'package:cruky/src/interfaces/app_material.dart';
import 'package:cruky/src/interfaces/plugin_app.dart';

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

  /// this is a list of used plugins in your app
  List<PluginApp> get plugins => [];

  /// this method called before the binding the http server.
  ///
  /// you must use this function if you want to define a global variable
  /// that has not initialized we run server in isolates so you must declare the global
  /// variable for every isolate.
  ///
  /// This method called once when the server first start and do not recall it in hot reload
  ///
  /// ```
  /// late final MySqlConnection conn;
  /// main() => runApp(MyApp(), debug: false);
  ///
  /// class MyApp extends ServerApp {
  ///   @override
  ///   List get routes => [get];
  ///
  ///   @override
  ///   List get middlewares => [];
  ///
  ///   @override
  ///   Future onlisten() async {
  ///     var settings = ConnectionSettings(
  ///       host: 'localhost',
  ///       port: 3306,
  ///       user: 'root',
  ///       password: 'root',
  ///       db: 'labdesk',
  ///     );
  ///     conn = await MySqlConnection.connect(settings);
  ///   }
  /// }
  /// ```
  ///
  /// This will work fine but this will not work:
  ///
  /// ```
  /// late final MySqlConnection conn;
  /// main() {
  ///    var settings = ConnectionSettings(
  ///       host: 'localhost',
  ///       port: 3306,
  ///       user: 'root',
  ///       password: 'root',
  ///       db: 'labdesk',
  ///    );
  ///    conn = await MySqlConnection.connect(settings);
  ///    runApp(MyApp(), debug: false);
  /// }
  ///
  /// class MyApp extends ServerApp {
  ///   @override
  ///   List get routes => [get];
  ///
  ///   @override
  ///   List get middlewares => [];
  /// }
  /// ```
  ///
  /// It will cause a error like:
  /// `Unhandled exception: LateInitializationError: Field 'conn' has not been initialized.`
  Future onlisten() async {}
}
