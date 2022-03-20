library todo;

import 'package:cruky/cruky.dart';

import 'parsers.dart';

void main(List<String> args) {}

@ModelParser([TodoParser])
createTodo(SimpleRequest request) {
  return {};
}
