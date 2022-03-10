import 'dart:io';

void printReq(HttpRequest req, String resType) {
  print("Method: " + req.method);
  print("Path: " + req.uri.path);
  print("Response: ${req.response.statusCode} -> $resType");
  print("==================================");
}
