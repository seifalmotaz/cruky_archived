`ServerApp` is the main app that the server will get the routes and all things from it like (port, host, routes, middlewares, plugins).
This class extends __AppMaterial__ and have the same getters.

## Getters

It has the same __AppMaterial__ getter plus:

| Name    | Type   | Description                                                           |
| ------- | ------ | --------------------------------------------------------------------- |
| port    | String | you can define a custom port to use here the default is __5000__      |
| address | String | you can define a custom host to use here the default is __127.0.0.1__ |
| plugins | List   | you can add plugins to the app                                        |

## Usage

```dart
class MyApp extends ServerApp {

  int get port => 80;
  String get address => '0.0.0.0';

  @override
  List get routes => [
      ExampleApp(),
  ];
}
```