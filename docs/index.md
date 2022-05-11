---
description: Cruky is a server-side library for the dart ecosystem to help you create your API as fast as possible
tags:
  - cruky
  - dart
  - api
  - API
---

# __cruky__

__cruky__ is a server-side library for the dart ecosystem to help you create your API as fast as possible. Cruky team want to make server-side apps with modern style and fast __high performance__.

The main reason why __cruky__ was built, because all libraries are focused on the Flutter ecosystem and not on dart language
and this makes the library have fewer futures than other frameworks or libraries like (Django, FastAPI, ROR, ..etc)
So __cruky team__ decided that we will make a new library that focuses on Dart and get the maximum performance using dart mirrors and code generators together to get the best usage of the dart.

__If you have any idea tell me in discussion section on github <a href="https://github.com/seifalmotaz/cruky/discussions/new?category=ideas" target="_blank">Submit new idea</a>__

> Inspired by server-side frameworks like (Django, Flask, FastAPI)

---

**Pub**: <a href="https://pub.dev/packages/cruky" target="_blank">https://pub.dev/packages/cruky</a>

<!-- **Documentation**: <a href="https://seifalmotaz.github.io/cruky/" target="_blank">https://seifalmotaz.github.io/cruky/</a> -->

**Source Code**: <a href="https://github.com/seifalmotaz/cruky" target="_blank">https://github.com/seifalmotaz/cruky</a>

**Issues**: <a href="https://github.com/seifalmotaz/cruky/issues" target="_blank">https://github.com/seifalmotaz/cruky/issues</a>

---


## Requirements

- Latest Dart version from [Dart.dev](https://dart.dev/)
- An editor like vcode or android studio.

## Installation

Install cruky globaly
```console
$ dart pub global activate cruky
```

create new project
```console
$ cruky create project_name
```

!!! note
    if you run cruky and get `bash: cruky: command not found` error you can do this:

     - try to run `cruky.bat create appName`
     - if it did not work add `C:\Users\{{Your name}}\AppData\Local\Pub\Cache\bin` to your enviroment variables

## Features

- [x] Simple code to start serving you api
- [x] Fast performance, this package is built with Dart lang and it's supporting multi isolates
- [x] Code editor helper __cruky team__ had made a vscode extention [cruky_snippets](https://marketplace.visualstudio.com/items?itemName=SeifAlmotaz.cruky-snippets) to help you to code faster
- [x] Static files handler
- [x] Web socket support
- [x] HTTPS support

## First lines

First we must define our main app or the server entry point that have all the routes we use in the app
as __Cruky__ recommend to name it `MyApp`


```dart title="bin/main.dart"
import 'package:cruky/cruky.dart';

class MyApp extends ServerApp {
  @override
  List get routes => [];

  @override
  List get pipeline => [];
}
```

We can define two main things the `routes` getter and `pipeline` getter:

- routes used to add the route methods for the app
- middlewares used to add global middleware for the routes inside this app

Second we can add some routes to the main app, we will create a route that response with json and contains a massege:

```dart title="bin/main.dart"
// rest of code

@Route.get('/')
Json getData(Request req) {
  return Json({'msg': "Hello world"});
  /// You can use text response too like this Text("Hello world")
}
```

We define an annotation first that contains the path then we add a method that handles the request and have a argument called `req` this argument has type `Request` that will help you get the request data easily like the (json, form, multipart/form)

Now we must add this method to the main app inside the `routes` getter:

```dart title="bin/main.dart"
// rest of code

class MyApp extends ServerApp {
  @override
  List get routes => [
      getData,
  ];

  @override
  List get pipeline => [];
}

// rest of code
```

Last thing add the main function that will run the app:

```dart title="bin/main.dart"
void main() => runApp(MyApp());
// rest of code
```

Now run the app with command
```console
$ cruky serve
- or
$ dart pub run cruky serve
- or
$ dart run --enable-vm-service --disable-service-auth-codes bin/main.dart
```