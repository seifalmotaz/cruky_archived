library todos; // library must be added and unique to add all routes in it

import 'package:cruky/cruky.dart';

List<Map> todos = [
  {"id": 1, "task": "task 1"},
  {"id": 2, "task": "task 2"},
];

/// serving the routes to http server
/// with hot reloading.
///
/// without hotreload:
/// ```dart
/// void main() => serve();
/// ```
void main() => serveWithHotReload();

@Route.get('/todos/list/')
Future<List> listTodos(SimpleRequest request) async => [...todos];

/// get the id from path parameters you can define `:id(int)` or `:id(string)` or `:id(double)`
/// , the parameter formate is `:nameOfField(type)` and the type is optional the default is string
@Route.get('/todos/:id(int)/')
Future<Map> getTodo(SimpleRequest request) async => {...todos[request['id']]};

/// get the task from form, there is two ways two to define request form type.
///
/// First is `FormRequest` form regular form request
/// , And secons is `iFormRequest` for multipart form
@Route.post('/todos/')
Future<List> createTodo(FormRequest request) async {
  Map newTodo = {"id": todos.length + 1};
  newTodo.addAll({"task": request['task']});
  todos.add(newTodo);
  return todos;
}

/// get the id fro path parameters
@Route.delete('/todos/:id(int)')
Map deleteTodo(SimpleRequest request) {
  todos.removeAt(request['id']);

  /// return custom status code
  return {
    #status: HttpStatus.ok,
    #body: {"msg": "the todo is deleted"}
  };
}
