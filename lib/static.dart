library static.static;

import 'dart:io';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/errors/exp_res.dart';

class _StaticFilesApp extends InApp {
  final String path;
  final String parentDir;
  final List<String> filesURIs;
  _StaticFilesApp(this.path, this.filesURIs, this.parentDir);

  @override
  String get prefix => path;

  @Route.any('/(.+)')
  handler(Request req) {
    RegExpMatch regex = req.regex;
    String filePath = regex.group(1)!;
    var split = filePath.split(RegExp(r'/|\\'));
    split.removeWhere((e) => e.isEmpty);
    filePath = split.join('/');
    Iterable<String> uri = filesURIs.where((e) => e.endsWith(filePath));
    if (uri.isEmpty) return ERes.e404();
    return FileRes(parentDir + '/' + filePath);
  }
}

InApp static(String folder, String expose) {
  List<String> filesPaths = [];
  List<FileSystemEntity> list = Directory(folder).listSync(recursive: false);
  for (var entity in list) {
    FileSystemEntityType type = FileSystemEntity.typeSync(entity.path);
    if (type == FileSystemEntityType.file) {
      var split = entity.path.split(RegExp(r'/|\\'));
      split.removeWhere((element) => element.isEmpty);
      split.removeAt(0);
      split.removeAt(0);
      String p = split.join('/');
      filesPaths.add(p);
    }
  }
  return _StaticFilesApp(expose, filesPaths, folder);
}
