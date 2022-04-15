library cruky.utils;

import 'dart:convert';

part './string_converter.dart';

extension UriCustom on Uri {
  static Map<String, List<String>> splitQueryStringMulti(String query,
      {Encoding encoding = utf8}) {
    return query.split("&").fold({}, (map, element) {
      int index = element.indexOf("=");
      if (index == -1) {
        if (element != "") {
          var s = Uri.decodeQueryComponent(element, encoding: encoding);
          if (!map.containsKey(s)) {
            map[s] = [];
          }
        }
      } else if (index != 0) {
        var key = element.substring(0, index);
        var value = element.substring(index + 1);
        var k = Uri.decodeQueryComponent(key, encoding: encoding);
        var v = Uri.decodeQueryComponent(value, encoding: encoding);
        if (map.containsKey(k)) {
          map[k]!.add(v);
        } else {
          map[k] = [v];
        }
      }
      return map;
    });
  }
}
