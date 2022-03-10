import 'dart:io';

void printReq(HttpRequest req) {
  print("Method: ${req.method} <- ${req.headers.contentType?.mimeType}");
  print("Path: " + req.uri.path);
  print("Response: ${req.response.statusCode} -> "
      "${req.response.headers.contentType?.mimeType}");
  print("=====================================");
}
