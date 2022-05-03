---
description: Schema Validator for request data 
tags:
  - schema
  - validator
---

# Schema Validator

Cruky has a schema validator option that can help you get the data from the request body and make sure that the data sent is in the correct spelling:

```dart
class Todo {
  String task;
  bool isCompleted;
  Todo(this.task, this.isCompleted);
}
```

To turn this class into a schema we must add a __Schema__ annotation to define from where to get this data and add a `parse` constructor:

```dart
@Schema.json()
class Todo {
  final String task;
  final bool isCompleted;
  Todo.parse(this.task, this.isCompleted);
}
```

and add it to the route handler:

```dart
@Route.get('/')
Map example(Request req, Todo todo) {
  return {
    "task": todo.task,
    "is_completed": todo.isCompleted,
  };
}
```

It will get the JSON body data and accept only the `application/json` content type.

!!! note
    1. You can only have one schema validator for this handler type.
    2. Do not forget to add the `parse` constructor.
    3. In the `parse` constructor __cruky__ accept both positioned and named arguments.