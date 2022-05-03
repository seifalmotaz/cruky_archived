---

description: Request body
tags:

- request
- body
- content type

---

# Request Body

You can get the request data by the __Request__ class, it will help you to manipulate the __HttpRequest__.

### Json `json`

__Request__ help you to convert the data to `Map` or `List` type:

```dart
@Route.get('/')
Future<Json> example(Request req) async {
  Map body = await req.json();
  return Json(body);
}
```

!!! info
    It uses __utf8__ to decode __HttpRequest__ stream.

### Form `x-www-form-urlencoded`

```dart
@Route.get('/')
Future<Text> example(Request req) async {
  FormData body = await req.form();
  print(body['data']) // print List<String>
  print(body.getInt('data')) // print int
  print(body.listInt('data')) // print List<int>
  return Text('ok');
}
```

This method will help you to get the form data as `Map<String, List<String>>` so you can get the data by `body['data']` bu if you want to get the data with spacific type like __int__ you can use `body.getInt('data')` or you can get a list of `int` by `body.listInt('data')`.

### Multipart form `multipart/form-data`

It has the same options that in `FormData` and __formFiles__ variable that contains a list of __FilePart__:

```dart
@Route.get('/')
Future<Text> example(Request req) async {
  iFormData body = await req.iForm();
  print(body.formFiles); // print Map<String, List<FilePart>>

  print(body['data']) // print List<String>
  print(body.getInt('data')) // print int
  print(body.listInt('data')) // print List<int>
  print(body['file']) // print List<FilePart>
  print(body.getFile('file')) // print FilePart
  return Text('ok');
}
```