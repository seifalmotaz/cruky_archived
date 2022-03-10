library cruky.handlers;

import 'dart:convert';
import 'dart:io';

import 'dart:mirrors';

part './method.dart';

abstract class RequestHandler {
  dynamic handler(HttpRequest req, Map<String, dynamic> pathParams);
}
