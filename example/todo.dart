import 'package:cruco/cruco.dart';

List<Map> todos = [
  {"id": 1, "task": "task 1"},
  {"id": 2, "task": "task 2"},
];

Future<void> main() async {
  Cruco cruco = Cruco();
  cruco.path('/').get(getTodo);
  cruco.path('/').post(createTodo);
  cruco.path('/list').get(listTodos);
  await cruco.serve();
}

Future<MapResponse> listTodos(CrucoRequest req) async => {#body: todos};
Future<Map> getTodo(CrucoRequest req) async => todos[(req.body['id'] ?? 1) - 1];

MapResponse createTodo(CrucoRequest req) {
  Map newTodo = {"id": todos.length + 1};
  newTodo.addAll({"task": req.body['task']});
  todos.add(newTodo);
  return {#status: HttpStatus.created};
}

MapResponse deleteTodo(CrucoRequest req) {
  todos.removeAt((req.body['id'] ?? 1) - 1);
  return {#status: HttpStatus.ok};
}
