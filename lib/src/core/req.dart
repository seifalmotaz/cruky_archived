library cruky.core.req;

import 'dart:io';

class Request {
  final HttpRequest req;

  final MapConverter query;
  final MapConverter path;
  final Map<Symbol, Object> parser = {};

  HttpResponse get res => req.response;
  String get method => req.method;
  Uri get uri => req.uri;
  HttpSession get session => req.session;

  String? headerValue(String i) => req.headers.value(i);

  Map<String, List<String>> get headers {
    Map<String, List<String>> data = {};
    req.headers.forEach((name, values) {
      data.addAll({name: values});
    });
    return data;
  }

  Request({
    required this.req,
    required Map<String, dynamic> pathParams,
    required Map<String, dynamic> query,
  })  : path = MapConverter<Map<String, dynamic>>(pathParams),
        query = MapConverter<Map<String, dynamic>>(query);
}

class MapConverter<T extends Map> {
  final T data;
  MapConverter(this.data);

  String? get(String i) => data[i];

  dynamic getAny(String i) => data[i];

  int? getInt(String i) {
    final _data = data[i];
    if (_data == null) return null;
    return int.tryParse(_data);
  }

  double? getDouble(String i) {
    final _data = data[i];
    if (_data == null) return null;
    return double.tryParse(_data);
  }

  bool? getBool(String i) {
    final _data = data[i];
    if (_data == null) return null;
    String ii = _data.toLowerCase();
    if (ii.contains('true')) return true;
    if (ii.contains('false')) return false;
    return null;
  }
}
