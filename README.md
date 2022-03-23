<p align="center">
  <img src="https://raw.githubusercontent.com/seifalmotaz/cruky/main/assets/logo/logo_transparent.png" alt="cruky library logo" width="420" height="420" \>
</p>

## Info

Cruky is a server-side library for the dart ecosystem to help you create your API as fast as possible. We want to make server-side apps with modern style and fast `high performance`

> Inspired by FastApi

## Get started

You can see the todo example in the examples file it's very clear to understand.

1. Install Dart from [Dart.dev](https://dart.dev/)

2. Install the Cruky package with `dart pub global activate cruky`

3. Create dart project with  `dart create nameOfProject`

4. open the project with your favorite IDE like  `vscode`

5. And let's get started

First, we must add a `library` name for the file to import all routes in it and it must be unique to import the package in the file

```dart
library todos;
import 'package:cruky/cruky.dart';

/// data model
final List todos = [
  {"id": 1, "task": "task 1"},
  {"id": 2, "task": "task 2"},
];
```

Now let's add our first route method:

```dart
@Route.get('/todos/list/')
Future<List> listTodos() async => [];
```

Add the `Route` annotation to specify the route path, and add the method under it we can use the `Future` method or regular method (async or sync).

## Return data from the method

You can return a List or map for now and the response content type is just JSON for now.

## Return specific status code

you can return the specific status code with the map like that:

```dart
@Route.delete('/todos/:id(int)')
Map deleteTodo(int id) {
  todos.removeAt(request[id]);
  /// return custom status code
  return {
    #status: HttpStatus.ok,
    #body: {"msg": "the todo is deleted"}
  };
}
```

## Now serve the app

we can serve a simple app with this code

```dart
void main() => serve(host: '127.0.0.1', port: 5000);
```

and now run the dart file with `cruky run filename`.

This will run the file in `./bin/filename.dart` with hot-reload.

> You can run with another folder with `cruky run filename -d example`
> 
> This will run the file in `./example/filename.dart`

Now Cruky will run the app with hot-reload if any thing changed in lib folder.
