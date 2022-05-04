---
description: Handlers Types used for routes methods
tags:
  - methods
  - handlers
---

# Route Handlers Types

Handler Type is a template for a method/function that will be executed as a handler for the route, Example:

__DirectHandler__ is the main method handler type that we had used until now, And the template looks like this:

```dart
dynamic methodName(Request req) {
    return "";
}
```

As we see the method can return any type of data and have one argument of __Request__.

If you changed the template to:

```dart
dynamic methodName(Request req, data) {
    return "";
}
```

This method will not be a type of __DirectHandler__ because the __DirectHandler__ has a specific argument that cannot be removed or add any other argument.

## DirectHandler

The first and the main handler type is the __DirectHandler__ and the infrastructure:

| Return Type | Method Args | Content Type |
| ----------- | ----------- | ------------ |
| Dynamic     | __Request__ | Any          |

## JsonHandler

A handler made specific for JSON content type request that will convert the request to `Map` type and pass it to the method.

| Return Type | Method Args | Content Type |
| ----------- | ----------- | ------------ |
| Dynamic     | __Map__     | JSON         |

## TextHandler

A handler made specific for text content type request that will convert the request to `String` and pass it to the method.

| Return Type | Method Args | Content Type |
| ----------- | ----------- | ------------ |
| Dynamic     | __String__  | Almost Any   |

!!! note
    The handler will convert the request to text using __utf8__ and pass it to the method.

    The handler can accept any content type request that can be converted to __String__.

## SchemaHandler

We have discussed this handler before in `Schema Validator`.

| Return Type | Method Args                   | Content Type                |
| ----------- | ----------------------------- | --------------------------- |
| Dynamic     | __Request__, __Schama class__ | As Schema annotation accept |

!!! danger
    In the `Method Args` column the args in the method have the same order of args.
