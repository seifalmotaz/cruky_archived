import 'dart:io';

class StatusCode {
  static e404(HttpRequest req) {
    req.response.statusCode = 404;
    req.response.write('Page not found.');
    req.response.close();
  }

  static e405(HttpRequest req) {
    req.response.statusCode = 405;
    req.response.write('Method not allowed.');
    req.response.close();
  }

  static e500(HttpRequest req) {
    req.response.statusCode = 500;
    req.response.write('Server error.');
    req.response.close();
  }
}
