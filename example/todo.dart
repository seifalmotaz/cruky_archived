library todos;

import 'package:cruco/cruco.dart';

List<Map> todos = [
  {"id": 1, "task": "task 1"},
  {"id": 2, "task": "task 2"},
];

void main() => serve();

@Route.get('/todos/list/')
Future<List> listTodos() async => todos;

@Route.get('/todos/')
Future<Map> getTodo() async => todos[0];

@Route.post('/todos/')
List createTodo() {
  Map newTodo = {"id": todos.length + 1};
  newTodo.addAll({"task": 'task ${todos.length + 1}'});
  todos.add(newTodo);
  return todos;
}

@Route.delete('/todos/')
MapResponse deleteTodo() {
  todos.removeAt(0);
  return {#status: HttpStatus.ok};
}
