import 'package:cruky/cruky.dart';

void main() => runApp(MyApp());

class MyApp extends ServerApp {
  @override
  List get routes => [
        exampleJson,
        exampleForm,
        exampleiForm,
      ];
}

@Route.get('/json')
Map exampleJson(Request req, Todo todo) {
  return {
    "task": todo.task,
    "is_completed": todo.isCompleted,
  };
}

@Route.get('/form')
Map exampleForm(Request req, TodoForm todo) {
  return {
    "task": todo.task,
    "is_completed": todo.isCompleted,
  };
}

@Route.post('/iform')
Map exampleiForm(Request req, TodoiForm todo) {
  return {
    "task": todo.task,
    "is_completed": todo.isCompleted,
  };
}

@Schema.json()
class Todo {
  final String task;
  final bool isCompleted;
  Todo.parse(this.task, this.isCompleted);
}

@Schema.form()
class TodoForm {
  final String task;
  final bool isCompleted;
  TodoForm.parse(this.task, this.isCompleted);
}

@Schema.iform()
class TodoiForm {
  final String task;
  final bool isCompleted;
  TodoiForm.parse(this.task, this.isCompleted);
}
