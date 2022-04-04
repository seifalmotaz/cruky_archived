import 'package:cruky/cruky.dart';

import '../db.dart';
import '../repos/todo.dart';

@Route.get('/list')
list(ReqCTX req) {
  return Json(todos
      .map((e) => {
            'task': e.task,
            'is_completed': e.isCompleted,
          })
      .toList());
}

@Route.get('/')
get(ReqCTX req) async {
  TodoModel todoModel = todos[(await req.json())['index']];
  return {
    'task': todoModel.task,
    'is_completed': todoModel.isCompleted,
  };
}

@Route.post('/')
create(ReqCTX req) async {
  final body = await req.json();
  final todo = TodoModel(body['task'], body['is_completed']);
  todos.add(todo);
  return {
    'task': todo.task,
    'is_completed': todo.isCompleted,
  };
}

@Route.delete('/')
delete(ReqCTX req) async {
  final body = await req.json();
  todos.remove(body['id']);
}
