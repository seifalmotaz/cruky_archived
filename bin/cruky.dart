import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:cruky/src/common/ansicolor.dart';

final String _serveCMD = 'serve';
final String _createCMD = 'create';

Future<void> main(List<String> args) async {
  var parser = ArgParser();
  parser.addCommand(_serveCMD);
  parser.addCommand(_createCMD);

  ArgResults results = parser.parse(args);
  ArgResults command = results.command!;
  if (command.name == _serveCMD) {
    String dir =
        command.arguments.isEmpty ? './bin/main.dart' : command.arguments.first;
    Process process = await Process.start('dart', [
      'run',
      '--enable-vm-service',
      '--disable-service-auth-codes',
      dir,
    ]);

    LineSplitter ls = LineSplitter();
    process.stdout
        .transform(utf8.decoder)
        .forEach((e) => print(ls.convert(e).join('\n')));

    process.stderr.transform(utf8.decoder).forEach((e) async {
      print('\n${danger('Error with you code:')}\n');
      print(ls.convert(e).join('\n'));
    });
    return;
  }

  if (command.name == _createCMD) {
    String appName = command.arguments.first;
    print('Creating dart project');
    await Process.run('dart', ['create', appName]);

    print('Editing dart project');
    Directory('./$appName/lib').createSync();

    File main = File('./$appName/bin/main.dart');

    if (!main.existsSync()) {
      main = main.renameSync('./$appName/bin/main.dart');
    }

    main.writeAsString("""
import 'package:cruky/cruky.dart';

void main() => runApp(MyApp());

class MyApp extends ServerApp {
  @override
  List get routes => [];

  @override
  List get middlewares => [];
}
""");
    print('Done...');
    print('\nRun this:');
    print('     cd $appName && dart pub add cruky');
  }
}
