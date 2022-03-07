library test.lib;

// import 'dart:mirrors';
import 'package:cruco/cruco.dart';

void main(List<String> args) => serve();

@Route.post('/')
Map getIt() {
  return {"Hellow": "world"};
}
