import 'dart:io';

abstract class StatusCodes {
  e404(HttpRequest req);
  e405(HttpRequest req);
  e500(HttpRequest req);
}

class TextStatusCodes extends StatusCodes {
  @override
  e404(HttpRequest req) {
    req.response.statusCode = 404;
    req.response.write('Page not found.');
    req.response.close();
  }

  @override
  e405(HttpRequest req) {
    req.response.statusCode = 405;
    req.response.write('Method not allowed.');
    req.response.close();
  }

  @override
  e500(HttpRequest req) {
    req.response.statusCode = 500;
    req.response.write('Server error.');
    req.response.close();
  }
}
