library todos;

import 'package:cruky/cruky.dart';

List<Map> todos = [
  {"id": 1, "task": "task 1"},
  {"id": 2, "task": "task 2"},
];

void main() => serve(port: 5678);

@Route.get('/list/')
void listTodos(SimpleReq req, ResCTX resCTX) async => resCTX.json(todos);

@Route.post('/', middlewares: [AuthMW])
createTodo(FormReq req, ResCTX resCTX) {
  Map newTodo = {"id": todos.length + 1};
  newTodo.addAll({"task": req['task']});
  todos.add(newTodo);
  resCTX.json(todos);
}

class AuthMW extends Middleware {
  @override
  bool before() {
    if (request.query.containsKey('key')) return false;
    return true;
  }
}
