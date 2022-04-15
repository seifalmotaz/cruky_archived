# Cruky

Cruky is a server-side library for the dart ecosystem to help you create your API as fast as possible. We want to make server-side apps with modern style and fast `high performance`.

The main reason why I built this is that all libraries are focused on the Flutter ecosystem and not on dart lang
and this makes the library have fewer futures than other frameworks or libraries like (Django, FastAPI, ROR, ..etc)
So I decided that I will make a new library that focuses on Dart and get the maximum performance using dart:mirrors and code generators together to get the best usage of the dart.

> Inspired by server-side frameworks like (Django, Flask, FastAPI, ROR)

***This is all frameworks that I learned.***

---

**Documentation**: <a href="https://seifalmotaz.github.io/cruky/" target="_blank">https://seifalmotaz.github.io/cruky/</a>

**Source Code**: <a href="https://github.com/seifalmotaz/cruky" target="_blank">https://github.com/seifalmotaz/cruky</a>

**Issues**: <a href="https://github.com/seifalmotaz/cruky/issues" target="_blank">https://github.com/seifalmotaz/cruky/issues</a>

---


## Requirements

- Install Dart from [Dart.dev](https://dart.dev/)
- run command `dart pub global activate cruky`
- Create new dart project
- Install **cruky** <a href="https://pub.dev/packages/cruky" target="_blank">https://pub.dev/packages/cruky</a>
- create `main.dart` file in bin directory and you ready to write your app

## First lines

First we must define our main app or the server entry point that have all the routes we use in the app
as I recommend to name it `MyApp`


```dart title="bin/main.dart"
import 'package:cruky/cruky.dart';

class MyApp extends ServerApp {
  @override
  List get routes => [];

  @override
  List get middlewares => [];
}
```

We can define two main things the `routes` getter and `middlewares` getter:

- routes used to add the route methods for the app
- middlewares used to add global middleware for the routes inside this app

Second we can add some routes to the main app, we will create a route that response with json and contains a massege:

```dart title="bin/main.dart"
// rest of code

@Route.get('/')
Json getData(ReqCTX req) {
  return Json({'msg': "Hello world"});
  /// You can use text response too like this Text("Hello world")
}
```

We define an annotiation first that contains the path then we add a method that handles the request and have a argument called `req` this argument has type `ReqCTX` that will help you get the request data easily like the (json, form, multipart/form)

Now we must add this method to the main app inside the `routes` getter:

```dart title="bin/main.dart"
// rest of code

class MyApp extends ServerApp {
  @override
  List get routes => [
      getData,
  ];

  @override
  List get middlewares => [];
}

// rest of code
```

Last thing add the main function that will run the app:

```dart title="bin/main.dart"
void main() => runApp(MyApp(), debug: true);
// rest of code
```

Now run the app with command `dart pub run cruky serve` or you can run `dart run --enable-vm-service --disable-service-auth-codes bin/main.dart` both are the same. this will run the app in debug mode with hot reload.