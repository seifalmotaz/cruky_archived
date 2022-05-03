---
description: InApp is the main thing that runs the server
tags:
  - InApp
  - routes
  - in app
---

# InApp

__InApp__ class helps you to add routes to the main app like the __AppMaterieal__ but does not has a routes getter instead you write the route method inside the class.

#### Example

```dart
class ExampleApp extends InApp {
  @override
  String get prefix => '/example';

  @Route.get('/')
  getExample(Request req) {
    return Text('InApp example');
  }
}
```

#### Getters

| Name     | Type   | Description                                                                           |
| -------- | ------ | ------------------------------------------------------------------------------------- |
| prefix   | String | this is a route path prefix that will be added as a prefix to all routes children.    |
| pipeline | List   | here you can add all your middleware to the app and it will be added to all children. |


