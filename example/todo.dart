library todos;

import 'dart:io';

import 'package:cruky/cruky.dart';

List<Map> todos = [
  {"id": 1, "task": "task 1"},
  {"id": 2, "task": "task 2"},
];

void main() => serve();

@Route.get('/todos/list/')
Future<List> listTodos() async => todos;

@Route.get('/todos/:id(int)/')
Future<Map> getTodo(int id) async => {...todos[id]};

@Route.post('/todos/')
List createTodo(String task) {
  Map newTodo = {"id": todos.length + 1};
  newTodo.addAll({"task": task});
  todos.add(newTodo);
  return todos;
}

@Route.delete('/todos/:id(int)')
Map deleteTodo(int id) {
  todos.removeAt(id);
  return {#status: HttpStatus.ok};
}
