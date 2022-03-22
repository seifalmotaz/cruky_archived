import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:watcher/watcher.dart';

final String run = 'run';
final String log = 'log';

Future<void> main(List<String> args) async {
  ArgParser parser = ArgParser();
  parser.addCommand(run);
  parser.addCommand(log);

  var results = parser.parse(args);

  ArgResults command = results.command!;
  if (command.name == run) await runApp(command.arguments.first);

  /// dart run bin/cruky.dart log main
  if (command.name == log) await readLogging(command.arguments.first);
}

Future<void> runApp(String file) async {
  bool inProcess = false;
  var process = await Process.start('dart', ['run', file]);
  process.stdout.transform(utf8.decoder).forEach(print);

  DirectoryWatcher('./lib').events.listen((event) async {
    if (inProcess) return;
    print('Restarting');
    inProcess = true;
    process.kill();
    await Future.delayed(const Duration(milliseconds: 300));
    process = await Process.start('dart', ['run', file]);
    process.stdout.transform(utf8.decoder).forEach(print);
    inProcess = false;
  });
}

Future<void> readLogging(String fileName) async {
  File logFile = File('./log/$fileName.log');
  List<String> data = await logFile.readAsLines();

  for (var item in data) {
    print(item);
  }
}
