<p align="center">
  <img src="https://raw.githubusercontent.com/seifalmotaz/cruky/main/assets/logo/logo_transparent.png" alt="cruky library logo" width="420" height="420" \>
</p>

## Info

Cruky is a server-side library for the dart ecosystem to help you create your API as fast as possible.
We want to make server-side apps with modern style and fast `high performance`
We designed it to be easy to use and learn. Less time reading docs.
This package is still in development but you can use it's pretty much stable and there is any bug or future you want tell us in Github issues.

> Inspired by FastApi

## Get started

You can see the todo example in the examples file it's very clear to understand.

1. Install Dart from [Dart.dev](https://dart.dev/)

2. Install the Cruky package with pubspec and GitHub for now

3. Create dart project with  `dart create nameOfProject`

4. open the project with your favorite IDE like  `vscode`

5. And let's get started

First we must add a `library` name for the file to import all routes in it and it must be unique to import the package in the file

```dart
library todos;
import 'package:cruky/cruky.dart';
```

Now let's add our first route method:

```dart
@Route.get('/todos/list/')
Future<List> listTodos(SimpleRequest request) async {
    return [];
}
```

Add the `Route` annotation to specify the route path, and add the method under it we can use the `Future` method or regular method (async or sync).

And add request parameter to the method to get the request data.

## Request types

We have support for the most popular requests content-type:

- `SimpleRequest` for the request does not have a content type
  
  path: for the request path `Uri`
  
  parameters: for the path parameters return `Map`
  
  query: for the request path query

- `FormRequest` for form content type request and contains 
  
  path: for the request path `Uri`
  
  form: for the request form body return `Map`
  
  parameters: for the path parameters return  `Map`
  
  query: for the request path query 

- `iFormRequest` for multipart form content type request and contains
  
  path: for the request path `Uri`
  
  form: for the request form body return `Map`
  
  files: for the request body return `Map<String, FilePart>`
  
  parameters: for the path parameters return `Map`
  
  query: for the request path query

- `JsonRequest` for JSON content type request and contains
  
  path: for the request path `Uri`
  
  body: for the request JSON body return `Map`
  
  files: for the request body return `Map<String, FilePart>`
  
  parameters: for the path parameters return `Map`
  
  query: for the request path query

## Return data from the method

You can return List or map for now and the response content type is just JSON for now but I will update it soon.

## Return specific status code

you can return the specific status code with the map like that:

```dart
@Route.delete('/todos/:id(int)')
Map deleteTodo(SimpleRequest request) {
  todos.removeAt(request['id']);
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
void main() => serve(host = '127.0.0.1', port = 5000);
```

and now run the dart file with `dart run filename.dart`.

You can use hotreload option with:

```dart
void main() => serveWithHotReload(host = '127.0.0.1', port = 5000);
```