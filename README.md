<p align="center">
  <img src="https://raw.githubusercontent.com/seifalmotaz/cruky/main/assets/logo/logo_transparent.png" alt="cruky library logo" width="420" height="420" \>
</p>

## Info

Cruky is a server-side library for the dart ecosystem to help you create your API as fast as possible. We want to make server-side apps with modern style and fast `high performance`.

The main reason why I built this is that all libraries are focused on the Flutter ecosystem and not on dart lang
and this makes the library have fewer futures than other frameworks or libraries like (Django, FastAPI, ROR, ..etc)
So I decided that I will make a new library that focuses on Dart and get the maximum performance using dart:mirrors and code generators together to get the best usage of the dart.

> Inspired by server-side frameworks like (Django, Flask, FastAPI, ROR)

## Get started

You can see the todo example in the examples file it's very clear to understand.

1. Install Dart from [Dart.dev](https://dart.dev/)

2. Install the Cruky package with `dart pub global activate cruky`

3. Create dart project with  `dart create nameOfProject`

4. open the project with your favorite IDE like  `vscode`

5. And let's get started

Start adding the entrypoint app

```dart
import 'package:cruky/cruky.dart';

class MyApp extends ServerApp {
  @override
  List get routes => [
        exampleWithGETRequest,
      ];
}
```

Now let's add our first route method:

```dart
@Route.get('/')
exampleWithGetRequest(ReqCTX req) {
  return Json({});
}
```

Add the `Route` annotation to specify the route path, and add the method under it we can use the `Future` method or regular method (async or sync).

## Return data from the method

You can return a List or map for now and the response content type is just JSON for now.

## Return specific status code

you can return the specific status code with the map like that:

```dart
@Route.get('/')
exampleWithGetRequest(ReqCTX req) {
  return Json({}, 201);
}
```

## Now serve the app

we can serve a simple app with this code

```dart
void main() => runApp(MyApp(), debug: true);
```

> You can run with `cruky serve`,
> This will run the file in `./lib/main.dart`
> with `hot reload`.
> 
> Note: In production mode better to use the `dart run` command
> for less ram use and better performance.

### You can disable hot reload with:
```dart
void main() => runApp(MyApp(), debug: false);
```

Now Cruky will run the app with hot-reload if any thing changed in lib folder.

## Let's add some middleware

We can add a before and after middleware.
The before middleware runs before calling the main route method handler,
And the after middleware is the opposite.

```dart
@BeforeMW()
middlewareExample(ReqCTX req) {
  if (req.headerValue('Token') == null) {
    return Text('Not Auth', 401);
  }
}
```

The `MW` is the short of MiddleWare.
The annotiation defines the type of middleware, There is two types `BeforeMW` amd `AfterMW`.

You can access the header values with the `headerValue` function, if you want the full access you can get the main `HttpRequest` data with `req.native` or the response with `req.response` as `HttpResponse`

If you want to not execute the next function you can (The main route method) you can return a response like in the example.

Now we will add this middleware to global middlewares in the app and any route under it well have the same middleware.

```dart
class MyApp extends ServerApp {
  @override
  List get routes => [
        exampleWithGETRequest,
      ];

  @override
  List get middlewares => [middlewareExample]; /// add this
}
```

Or you can add the middleware scoped for a route like this:

```dart
@Route.get('/', [middlewareExample])
exampleWithGetRequest(ReqCTX req) {
  return Json({}, 201);
}
```