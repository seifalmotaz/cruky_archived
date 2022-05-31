library cruky.scanner;

import 'dart:io';
import 'dart:mirrors';

import 'package:cruky/src/annotation/annotation.dart';
import 'package:cruky/src/common/string_converter.dart';
import 'package:cruky/src/path/handler.dart';
import 'package:cruky/src/errors/liberrors.dart';
import 'package:cruky/src/handlers/middleware/main.dart';
import 'package:cruky/src/handlers/routes/abstract.dart';
import 'package:cruky/src/interfaces.dart';
import 'package:cruky/src/path/pattern.dart';
import 'package:cruky/src/scanner/method.dart';

import 'middleware.dart';

class PipelineMock {
  final List<Middleware> pre;
  final List<Middleware> post;
  PipelineMock(this.pre, this.post);
  PipelineMock copy() => PipelineMock(List.of(pre), List.of(post));
}

Future<List<PathHandler>> scan<T extends ServerApp>(T app) async {
  final List appPipelineMock = app.pipeline; // app pipeline/middleware
  final List appRoutes = app.routes; // app routes
  // adding plugins routes and pipelines to the main app data
  for (var item in app.plugins) {
    appPipelineMock.addAll(item.pipeline);
    appRoutes.addAll(item.routes);
  }

  // main pipeline
  PipelineMock pipeline = await getPipelineMock(appPipelineMock);
  // get routes mock
  List<RouteMock> unsorted =
      await getRoutes(appRoutes, pipeline, app.prefix.getUrlSegmants());
  unsorted.sort((a, b) => a.path.compareTo(b.path)); // sort routes

  List<List<RouteMock>> sorted = [];

  {
    // sorting
    String? path;
    List<RouteMock> list = [];
    for (var i = 0; i <= unsorted.length; i++) {
      if (i == unsorted.length) {
        if (list.isNotEmpty) sorted.add(list);
        continue;
      }
      var route = unsorted[i];
      if (path == null) {
        path = route.path;
        list = [route];
      } else {
        if (route.path == path) {
          list.add(route);
        } else {
          if (list.isNotEmpty) sorted.add(list);
          path = route.path;
          list = [route];
        }
      }
    }
  }

  // final result of routes tree
  final List<PathHandler> routesTree = [];

  for (var routeList in sorted) {
    String path = routeList.first.path;
    final Map<String, RouteHandler> methods = {};
    for (var route in routeList) {
      for (var i in route.methods) {
        methods[i] = route.handler;
      }
    }
    routesTree.add(PathHandler(
      methods: methods,
      path: path,
      pattern: PathPattern.parse(path),
    ));
  }

  for (var static in app.statics.entries) {
    final String parentDir = static.key;
    String exposePath = (static.value.split(RegExp(r'\/|\\'))
          ..removeWhere((e) => e.isEmpty))
        .join('/');
    exposePath = '/$exposePath/:path(path)/';

    List<String> filesPaths = [];
    {
      List<FileSystemEntity> list;
      try {
        list = Directory(parentDir).listSync(recursive: true);
      } on FileSystemException {
        throw FileSystemException(
            "Did not find the directory"
            "\n- Try to add `./` before the folder name if it's the command line working directory."
            "\n- Or add the full path directory.",
            parentDir);
      }
      for (var entity in list) {
        FileSystemEntityType type = FileSystemEntity.typeSync(entity.path);
        if (type == FileSystemEntityType.file) {
          var split = entity.path.split(RegExp(r'/|\\'));
          split.removeWhere((element) => element.isEmpty);
          {
            var s = parentDir.split(RegExp(r'/|\\'));
            split.removeWhere((element) => s.contains(element));
          }
          String p = split.join('/');
          filesPaths.add(p);
        }
      }
    }

    routesTree.add(StaticHandler(
      parentDir: parentDir,
      filesURIs: filesPaths,
      methods: {},
      pattern: PathPattern.parse(exposePath),
      path: exposePath,
    ));
  }
  return routesTree;
}

// filtred pipeline pre and post pipelines
Future<PipelineMock> getPipelineMock(List pipelineList) async {
  final Set pipelineMock = filterMW(pipelineList);
  final MiddlewareParser parser = MiddlewareParser();
  for (var item in pipelineMock.first) {
    await parser.parse(item, true);
  }
  for (var item in pipelineMock.last) {
    await parser.parse(item, false);
  }
  return PipelineMock(parser.pre, parser.post);
}

Future<List<RouteMock>> getRoutes(
    List appRoutes, PipelineMock pipeline, List<String> prefix) async {
  MethodParser methodParser = MethodParser([]);
  for (var i in appRoutes) {
    if (i is Function) {
      await methodParser.parse(i, prefix, pipeline.copy());
      continue;
    }
    if (i is AppMaterial) {
      PipelineMock line = await getPipelineMock(i.pipeline);
      PipelineMock _pipeline = pipeline.copy()
        ..pre.addAll(line.pre)
        ..post.addAll(line.post);
      methodParser.list.addAll(await getRoutes(
          i.routes, _pipeline, prefix + i.prefix.getUrlSegmants()));
      continue;
    }
    if (i is InApp) {
      var reflected = reflect(i);
      List<Function> routes = reflected.type.declarations.values
          .whereType<MethodMirror>()
          .where((e) => e.isRegularMethod)
          .map<Function>((e) => reflected.getField(e.simpleName).reflectee)
          .toList();
      PipelineMock line = await getPipelineMock(i.pipeline);
      PipelineMock _pipeline = pipeline.copy()
        ..pre.addAll(line.pre)
        ..post.addAll(line.post);
      methodParser.list.addAll(await getRoutes(
          routes, _pipeline, prefix + i.prefix.getUrlSegmants()));
    }
  }
  return methodParser.list;
}

Set<List<ClosureMirror>> filterMW(List mw) {
  List<ClosureMirror> pre = [];
  List<ClosureMirror> post = [];
  for (var item in mw) {
    var ref = reflect(item) as ClosureMirror;
    var function = ref.function;
    bool? isPre;
    for (var anno in function.metadata) {
      if (anno.reflectee is UsePre) {
        isPre = true;
      } else if (anno.reflectee is UsePost) {
        isPre = false;
      }
    }

    if (isPre != null) {
      if (isPre) pre.add(ref);
      if (!isPre) post.add(ref);
    } else {
      throw LibError.stack(
          function.location!,
          'The middleware method named "${MirrorSystem.getName(function.simpleName)}"'
          ' cannot be a middleware without annotation');
    }
  }
  return {pre, post};
}
