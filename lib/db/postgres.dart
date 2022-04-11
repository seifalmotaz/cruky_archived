library cruky.plugins.postgres;

import 'package:cruky/cruky.dart';
import 'package:cruky/src/interfaces/plugin_app.dart';
import 'package:postgres/postgres.dart';

export 'package:postgres/postgres.dart';

late PostgreSQLConnection postgres;

class PostgresPlugin extends PluginApp {
  String host;
  int port;
  String? user;
  String? password;
  String db;
  bool useSSL;

  /// The timeout for connecting to the database and for all database operations.
  Duration timeout;

  /// The default timeout for [PostgreSQLExecutionContext]'s execute and query methods.
  final int queryTimeoutInSeconds;

  /// The timezone of this connection for date operations that don't specify a timezone.
  final String timeZone;

  /// If true, connection is made via unix socket.
  final bool isUnixSocket;

  /// If true, allows password in clear text for authentication.
  final bool allowClearTextPassword;

  PostgresPlugin({
    this.host = 'localhost',
    this.port = 3306,
    this.user,
    this.password,
    required this.db,
    this.useSSL = false,
    this.timeout = const Duration(seconds: 30),
    this.queryTimeoutInSeconds = 30,
    this.timeZone = 'UTC',
    this.isUnixSocket = false,
    this.allowClearTextPassword = false,
  });

  @override
  Future onlisten() async {
    postgres = PostgreSQLConnection(
      host,
      port,
      db,
      username: user,
      password: password,
      timeoutInSeconds: timeout.inSeconds,
      useSSL: useSSL,
      allowClearTextPassword: allowClearTextPassword,
      isUnixSocket: isUnixSocket,
      queryTimeoutInSeconds: queryTimeoutInSeconds,
      timeZone: timeZone,
    );
    try {
      await postgres.close();
    } catch (e) {
      //
    }
    await postgres.open();
  }
}
