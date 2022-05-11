---
description: ServerApp is the main app that the server will get the routes and all things from it like (port, host, routes, middlewares, plugins)
tags:
  - ServerApp
  - route
  - server app
  - method handler
---

# ServerApp

`ServerApp` is the main app that the server will get the routes and all things from it like (port, host, routes, middlewares, plugins).
This class extends __AppMaterial__ and has the same getters.

## Getters

It has the same __AppMaterial__ getter plus:

| Name    | Type     | Description                                                                                           |
| ------- | -------- | ----------------------------------------------------------------------------------------------------- |
| name    | String   | app unique name for multi apps serve                                                                  |
| init    | Function | a method that will call on every isolate to run the server with the returned data from __ServerBind__ |
| plugins | List     | you can add plugins to the app                                                                        |

## Usage

```dart
class MyApp extends ServerApp {
  String get name => 'MyApp';

  ServerBind init() => ServerBind(
    address: '127.0.0.1',
    port: 5000,
    listeners: 2, // number of HttpServer listeners
  );

  @override
  List get routes => [
      ExampleApp(),
  ];
}
```

### Https

You can use the HTTPS listener if you define a securityContext field in __ServerBind__ 