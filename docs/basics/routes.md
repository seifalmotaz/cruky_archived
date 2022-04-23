# Route Handlers

Route handlers are functions/methods that handle the request with a specific path, and they can have middlewares before it or after.

You can respond with the __Response__ class.

## Usage

As we said the method must have a path to knowing what path this method handles

so we define __Route__ annotation for the method.



### Route annotation

##### Main constructor

The main constructor has two required arguments and two optional and all of them are positional arguments.

```dart
const Route(
   this.path, // define the method path
   this.methods, [ // define the accepted methods like "PUT, POST"
   this.middlewares = const [], // adding scoped middlwares
   this.accepted = const [], // adding the accepted content type request
]);
```

##### Constructors

Some constructors will help you save some time.

- The first constructors are the methods helper:

| Name   | Description                                                      |
| ------ | ---------------------------------------------------------------- |
| get    | This is a constructor that defines a route with the "GET" method |
| post   | defines a route with the "POST" method                           |
| put    | defines a route with the "PUT" method                            |
| delete | defines a route with the "DELETE" method                         |

- The second constructors are the methods and content type helper:
  
  constructors that have JSON content type in the accepted arg
  
  | Name    | Description                                                      |
  | ------- | ---------------------------------------------------------------- |
  | jget    | This is a constructor that defines a route with the "GET" method |
  | jpost   | defines a route with the "POST" method                           |
  | jput    | defines a route with the "PUT" method                            |
  | jdelete | defines a route with the "DELETE" method                         |

### Handler method

There are several types of handler methods that you can use we will discuss the basic one on this page.



After writing the annotation we define the method under it:

```dart
@Route.get('/my/path')
Json example(ReqCTX req) {
  return Json({'token': req.data['token']});
}
```

As we saw we defined the handler method with path __/my/path/__ and it responds with __Json__ class that extends __Response__ class.

From the `req` argument you can access some of the request helpers functions like:

- you can access the JSON body from the request if the request content type is __application/json__ 

- or you can get the form data if content type is __application/x-www-form-urlencoded__ 

- or can get multipart form data if the content type __multipart/form-data__

- you can also get the path query data, path parameters or headers like `req['field_name']`