import 'package:cruky/cruky.dart';

@Parser('todo')
class TodoParser {
  String task;
  bool isCompleted;
  TodoParser({
    required this.task,
    required this.isCompleted,
  });
}

@Parser('note')
class NoteParser {
  String note;
  List<String> labels;
  NoteParser({
    required this.note,
    this.labels = const [],
  });
}
