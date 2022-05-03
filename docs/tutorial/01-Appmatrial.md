---
description: AppMaterial is the main thing that runs the server
tags:
  - AppMaterial
  - pipeline
  - routes
  - app material
---

# AppMaterial

`AppMaterial` is the main thing that runs the server, it contains the main things that every app needs.

## Getters

| Name     | Type   | Description                                                                                                                                               |
| -------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| prefix   | String | this is a route path prefix that will be added as a prefix to all routes children.                                                                        |
| routes   | List   | here we can define all the method handlers and routes. you simply add the function that has the annotation `Route` and it will add it to the routes tree. |
| pipeline | List   | here you can add all your middleware to the app and it will be added to all children.                                                                     |

## Usage

Let's make an example. first, we define a class that extends the `AppMaterial` interface and adds routes and the prefix getter with path "/example":

```dart
class ExampleApp extends AppMaterial {
    @override
    String get prefix => '/example/';

    @override
    List get routes => [];
}
```

Now try to add a new route to the route tree like:

```dart
class ExampleApp extends AppMaterial {
    @override
    String get prefix => '/example/';

    @override
    List get routes => [getData];

    @Route.get('/')
    Json getData(Request req) {
        return Text("Hello world");
    }
}
```

Now you can add this app to the routes tree by adding it to the main entry app:

```dart
import 'package:cruky/cruky.dart';

void main() => runApp(MyApp(), debug: true);

class MyApp extends ServerApp {
  @override
  List get routes => [
      ExampleApp(),
  ];
}

class ExampleApp extends AppMaterial {
    @override
    String get prefix => '/example/';

    @override
    List get routes => [
        example,
    ];

    @Route.get('/main')
    Text example(Request req) {
        return Text("Hello world");
    }
}
```

And run the app with `dart pub run cruky serve`
Try to go to `localhost:5000/example/main` and you will get the `Hello world` response.

__Cruky__ supports nested apps which means you can add an app to the __ExampleApp__ routes and it will have the prefix `/example/` and the child app prefix.