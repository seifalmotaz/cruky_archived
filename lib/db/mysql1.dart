library cruky.plugins.mysql1;

import 'package:cruky/src/interfaces/plugin_app.dart';
import 'package:mysql1/mysql1.dart';

export 'package:mysql1/mysql1.dart';

late MySqlConnection mysql1;

class Mysql1Plugin extends PluginApp {
  String host;
  int port;
  String? user;
  String? password;
  String? db;
  bool useCompression;
  bool useSSL;
  int maxPacketSize;
  int characterSet;

  /// The timeout for connecting to the database and for all database operations.
  Duration timeout;

  Mysql1Plugin({
    this.host = 'localhost',
    this.port = 3306,
    this.user,
    this.password,
    this.db,
    this.useCompression = false,
    this.useSSL = false,
    this.maxPacketSize = 16 * 1024 * 1024,
    this.timeout = const Duration(seconds: 30),
    this.characterSet = CharacterSet.UTF8MB4,
  });

  @override
  Future onlisten() async {
    var settings = ConnectionSettings(
      db: db,
      host: host,
      port: port,
      user: user,
      useSSL: useSSL,
      timeout: timeout,
      password: password,
      characterSet: characterSet,
      maxPacketSize: maxPacketSize,
      useCompression: useCompression,
    );
    try {
      await mysql1.close();
    } catch (e) {
      //
    }
    mysql1 = await MySqlConnection.connect(settings);
  }
}
