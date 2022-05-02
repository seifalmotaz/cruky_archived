import 'dart:io';

import 'package:cruky/cruky.dart';

void main() => runApp(MyApp());

class MyApp extends ServerApp {
  @override
  List get pipeline => [pipelinePre, pipelinePost];

  @override
  List get routes => [
        example,
      ];
}

@UsePre()
pipelinePre(Request req) {
  print('pre');
}

@UsePost()
pipelinePost(Request req) {
  print('post');
}

@Route.get('/')
Future example(WebSocket socket) async {
  print('obj');
  socket.listen((event) {
    print(event);
    if (event == 'close') {
      socket.add("Server is closing the socket");
      socket.close();
    }
  });
}
