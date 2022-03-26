library todos; // library must be added and unique to add all routes in it

import 'package:cruky/cruky.dart';

List<Map> todos = [
  {"id": 1, "task": "task 1"},
  {"id": 2, "task": "task 2"},
];

/// serving the routes to http server.
void main() => serve();

@Route.get('/todos/list/')
Future listTodos(SimpleReq req) async => todos;

/// get the id from path parameters you can define `:id(int)` or `:id(string)` or `:id(double)`
/// , the parameter formate is `:nameOfField(type)` and the type is optional the default is string
@Route.get('/todos/:id(int)/')
Future getTodo(SimpleReq req) async => todos[req['id']];

/// get the task from form, there is two ways two to define request form type.
///
/// First is `FormReq` form regular form request
/// , And secons is `iFormReq` for multipart form
@Route.post('/todos/')
Future createTodo(FormReq req) async {
  Map newTodo = {"id": todos.length + 1};
  newTodo.addAll({"task": req['task']});
  todos.add(newTodo);
  return todos;
}

/// get the id fro path parameters
@Route.delete('/todos/:id(int)')
Map deleteTodo(SimpleReq req) {
  todos.removeAt(req['id']);

  /// return custom status code
  return {
    #status: HttpStatus.ok,
    #body: {"msg": "the todo is deleted"}
  };
}
