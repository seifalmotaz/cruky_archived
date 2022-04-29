import 'package:cruky/cruky.dart';

void main() => runApp(MyApp());

class MyApp extends ServerApp {
  @override
  List get routes => [
        example,
      ];
}

@Route.get('/')
Map example(Todo req) {
  return {
    "task": req.task,
    "is_completed": req.isCompleted,
  };
}

@Schema.json()
class Todo {
  @BindFrom.json()
  final String task;

  @BindFrom.json()
  final String isCompleted;

  const Todo.parse({
    required this.task,
    required this.isCompleted,
  });
}
