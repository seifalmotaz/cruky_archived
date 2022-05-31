import 'dart:io';

import 'package:args/args.dart';

final String _serveCMD = 'serve';
final String _createCMD = 'create';

Future<void> main(List<String> args) async {
  var parser = ArgParser();
  parser.addCommand(_serveCMD);
  parser.addCommand(_createCMD);

  ArgResults results = parser.parse(args);
  ArgResults command = results.command!;

  if (command.name == _createCMD) {
    String appName = command.arguments.first;
    print('Creating dart project');
    await Process.run('dart', ['create', appName]);
    await Process.run('dart', ['pub', 'add', 'cruky'],
        workingDirectory: './$appName');

    print('Editing dart project');
    Directory('./$appName/lib').createSync();

    File main = File('./$appName/bin/$appName.dart');

    if (main.existsSync()) {
      main = main.renameSync('./$appName/bin/main.dart');
    }

    main.writeAsString("""
import 'package:cruky/cruky.dart';

void main() => runApp(MyApp());

class MyApp extends ServerApp {
  @override
  List get routes => [];

  @override
  List get pipeline => [];
}
""");
    print('\n=> Done');
    print('Run:');
    print('  cd $appName');
    print('  dart pub run cruky serve');
  }
}
