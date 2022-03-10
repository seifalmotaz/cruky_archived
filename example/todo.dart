library todos; // library must be added and unique to add all routes in it

import 'dart:io';

import 'package:cruky/cruky.dart';

List<Map> todos = [
  {"id": 1, "task": "task 1"},
  {"id": 2, "task": "task 2"},
];

// serving the routes to http server
void main() => serve();

@Route.get('/todos/list/')
Future<List> listTodos() async => todos;

// get the id fro path parameters
@Route.get('/todos/:id(int)/')
Future<Map> getTodo(int id) async => {...todos[id]};

// get the task from json body or path query
@Route.post('/todos/')
List createTodo(String task) {
  Map newTodo = {"id": todos.length + 1};
  newTodo.addAll({"task": task});
  todos.add(newTodo);
  return todos;
}

// get the id fro path parameters
@Route.delete('/todos/:id(int)')
Map deleteTodo(int id) {
  todos.removeAt(id);
  return {#status: HttpStatus.ok};
}
