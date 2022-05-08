---
description: Web sockets
tags:
  - methods
  - handlers
---

# Web Sockets

> WebSockets are one of many different tools for building web applications that provide instant, real-time updates, and communication. The WebSocket Protocol establishes full-duplex, bidirectional communication between a client and server.
> 
> [Google search](https://www.pubnub.com/guides/what-are-websockets-and-when-should-you-use-them/)

To use a web socket we use __WebSocketHandler__, It's one of the __Route Handlers Type__.

| Return Type | Method Args   | Content Type |
| ----------- | ------------- | ------------ |
| Void        | __WebSocket__ | None         |

#### Example

```dart
import 'dart:io';

@Route.ws('/')
void example(WebSocket socket) { // you can use Future<void> for async method
  // listen to data from the socket
  socket.listen((event) {
    print(event);
    if (event == 'close') {
      // send data
      socket.add("Server is closing the socket");
      // close the socket
      socket.close();
    }
  });
}
```

!!! danger
    The middleware after `That have UsePost annotation` the main method will not be executed.
