library todos;

import 'package:cruco/cruco.dart';

List<Map> todos = [
  {"id": 1, "task": "task 1"},
  {"id": 2, "task": "task 2"},
];

void main() => serve();

@Route.get('/todos/list/')
Future<List> listTodos() async => todos;

@Route.get('/todos/:id(int)/')
Future<Map> getTodo(double id) async => {...todos[id.round()]};

@Route.post('/todos/')
List createTodo() {
  Map newTodo = {"id": todos.length + 1};
  newTodo.addAll({"task": 'task ${todos.length + 1}'});
  todos.add(newTodo);
  return todos;
}

@Route.delete('/todos/:id(int)')
MapResponse deleteTodo(int id) {
  todos.removeAt(id);
  return {#status: HttpStatus.ok};
}
