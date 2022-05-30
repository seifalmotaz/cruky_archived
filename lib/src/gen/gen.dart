library cruky.gen;

import 'package:cruky/src/path/handler.dart';

Future<void> genOpenApi(List<PathHandler> routes) async {
  // final Map docs = {
  //   "openapi": "3.0.2",
  //   "info": {"title": "API docs", "version": "0.1.0"},
  //   "paths": {},
  // };
  // final Map paths = docs['paths'];

  // for (var route in routes) {
  //   Set data =
  //       PathPattern.openapi(route.path); // return path and path parameters
  //   var correctPath = "/${data.first}/";
  //   paths[correctPath] = {};
  //   final Map path = paths[correctPath];
  //   for (var method in route.methods.entries) {
  //     var openapi = await method.value.openapi(data.last);
  //     if (openapi != null) {
  //       path[method.key.toLowerCase()] = openapi;
  //     }
  //   }
  // }

  // File file = File('./api/api.json');
  // file.writeAsStringSync(jsonEncode(docs));
}
