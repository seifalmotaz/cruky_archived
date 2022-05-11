---
description: Handlers Types used for routes methods
tags:
  - methods
  - handlers
---

# Isolates

You can run the app in multiple isolates to have faster performance.

We have two concepts:

#### Isolates

That means running the server app on 2 or more isolates and every isolate runs the same app.

For more on [Concurrency in Dart](https://dart.dev/guides/language/concurrency)

#### Listeners

When __cruky__ starts the server for an app it uses the `HttpServer.bind` method and starts listening to the requests.

We can have multiple listeners for the same app in a single isolate.

For more on [HttpServer class](https://api.dart.dev/stable/2.16.2/dart-io/HttpServer-class.html)

### Example

```dart
void main() => runApp(
      MyApp(),
      isolates: 2, // run in two isolate
    );

class MyApp extends ServerApp {
  ServerBind init() => ServerBind(
    address: '127.0.0.1',
    port: 5000,
    listeners: 2, // start 2 listeners for this app
  );
  @override
  List get routes => [
        example,
        ExampleApp(),
      ];
}
```

In this example, we used isolates and listeners.

This code run the app in two isolates and in every isolate starts three listeners.