import 'dart:convert';
import 'dart:io';

class Response {
  late HttpResponse _httpResponse;
  set response(HttpResponse res) => _httpResponse = res;

  void json(Map body) {
    _httpResponse.headers.contentType = ContentType.json;
    _httpResponse.write(jsonEncode(body));
  }
}
