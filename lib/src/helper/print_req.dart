import 'dart:io';

void printReq(HttpRequest req) {
  print("Method: ${req.method} <- ${req.headers.contentType?.mimeType}\n"
      "Path: ${req.uri.path}\n"
      "Response: ${req.response.statusCode} -> "
      "${req.response.headers.contentType?.mimeType}\n"
      "=====================================");
}
