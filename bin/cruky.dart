import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:args/args.dart';
import 'package:watcher/watcher.dart';

final String _run = 'run';
final String _log = 'log';

AnsiPen green = AnsiPen()..green();
AnsiPen blue = AnsiPen()..blue();
AnsiPen gray = AnsiPen()..gray();
AnsiPen red = AnsiPen()..red();
AnsiPen yellow = AnsiPen()..yellow();

Future<void> main(List<String> args) async {
  ArgParser parser = ArgParser();
  parser.addCommand(_run);
  parser.addCommand(_log);

  parser.addOption('dir', abbr: 'd');

  ArgResults results = parser.parse(args);
  ArgResults command = results.command!;

  if (command.name == _run) await runApp(results);

  /// dart run bin/cruky.dart log main
  if (command.name == _log) await readLogging(results.arguments.first);
}

Future<void> runApp(ArgResults results) async {
  late String dir;
  String file = results.command!.arguments.first;
  if (results.options.contains('dir')) dir = results['dir'];
  if (!results.options.contains('dir')) dir = './bin';

  bool inProcess = false;
  String filePath = '$dir/$file.dart';
  if (!(await File(filePath).exists())) {
    print('There is no file with this path: $filePath');
    return;
  }

  late Process process;

  start() async {
    process = await Process.start('dart', ['run', filePath]);

    LineSplitter ls = LineSplitter();
    process.stdout
        .transform(utf8.decoder)
        .forEach((e) => print(ls.convert(e).join('\n')));
  }

  await start();

  DirectoryWatcher('./lib').events.listen((event) async {
    if (inProcess) return;
    print('\n${gray("Change:")} in:${event.path.replaceAll(r'\', '/')}');
    print(green('===== Restarting =====\n'));
    inProcess = true;
    process.kill();
    await start();
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
