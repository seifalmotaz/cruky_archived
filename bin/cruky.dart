import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:watcher/watcher.dart';

final String run = 'run';

Future<void> main(List<String> args) async {
  ArgParser parser = ArgParser();
  parser.addCommand(run);

  var results = parser.parse(args);

  ArgResults command = results.command!;
  if (command.name == run) await runApp(command.arguments.first);
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
