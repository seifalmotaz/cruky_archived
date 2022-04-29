---
description: Path parameters
tags:
  - path
  - parameters
  - path type
---
# Path Parameters
You can declare path parameters in the __Route__ path string:

```dart hl_lines="1 3"
@Route.get('/my/:id')
Json example(Request req) {
  String myId = req.path['id'];
  return Json({'id': myId});
}
```

By adding `:` and the name of the parameter like `:id` or `:name`. you can get the parameter data from the path variable in request `req.path['parameter']`.

### Types
You can get a specific type of parameter by adding a type validator to the path parameter:

```dart hl_lines="1"
@Route.get('/my/:id(int)')
Json example(Request req) {
  int myId = req.path['id'];
  return Json({'id': myId});
}
```

The default type is a string but there are other types like `int`, `double`, `num`, and `string`.

!!! note
    if you set a type for path parameter like the above example if anyone tries to send a request to `/my/string` will get __404__ massage.