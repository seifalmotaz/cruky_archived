# App Matrial

`AppMatrial` is the main thing that runs the server, it contains the main things that every app need.

## Getters

| Name       | Type            | Discription                                                                                                                                               |
|------------|-----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| prefix     | String          | this is a route path prefix that will be added as prefix to all routes children.                                                                          |
| routes     | List | here we can define all the method handlers and routes. you simply add the function the has the annotiation `Route` and it will add it to the routes tree. |
| middlwares | List | this is a route path prefix that will be added as prefix to all routes children.                                                                          |

## Usage

Let's make an example. first we define a class that extends the `AppMatrial` interface and adding routes and the prefix getter with path "/example":

```dart
class ExampleApp extends AppMatrial {
    @override
    String get prefix => '/example/';

    @override
    List get routes => [];
}
```

Now try to add a new route to the route tree like:

```dart
class ExampleApp extends AppMatrial {
    @override
    String get prefix => '/example/';

    @override
    List get routes => [getData];

    @Route.get('/')
    Json getData(ReqCTX req) {
    return Text("Hello world");
    }
}
```

Now you can add this app to the routes tree with adding it to the main entry app:

```dart
import 'package:cruky/cruky.dart';

void main() => runApp(MyApp(), debug: true);

class MyApp extends ServerApp {
  @override
  List get routes => [
      ExampleApp(),
  ];
}

class ExampleApp extends AppMatrial {
    @override
    String get prefix => '/example/';

    @override
    List get routes => [
        example,
    ];

    @Route.get('/main')
    Text example(ReqCTX req) {
        return Text("Hello world");
    }
}
```

And run the app with `dart pub run cruky serve`
Try to go to `localhost:5000/example/main` and you will get the `Hello world` response.

Cruky supports nested apps that means you can add an app to the __ExampleApp__ routes and it will have the prefix `/example/` and the child app prefix.