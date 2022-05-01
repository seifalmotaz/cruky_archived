import 'dart:convert';

extension StringUtils on String {
  List<String> getUrlSegmants() {
    String i = replaceAll(r'\', '/');
    var split = i.split('/');
    split.removeWhere((e) => e.isEmpty);
    return split;
  }

  int? toInt([int? defaultValue]) {
    return int.tryParse(this) ?? defaultValue;
  }

  double? toDouble([double? defaultValue]) {
    return double.tryParse(this) ?? defaultValue;
  }

  num? toNum([num? defaultValue]) {
    return num.tryParse(this) ?? defaultValue;
  }

  bool? toBool([bool? defaultValue]) {
    String i = toLowerCase();
    if (i == "true") {
      return true;
    } else if (i == "false") {
      return false;
    }

    return defaultValue;
  }

  List? toList([List? defaultValue]) {
    try {
      return json.decode(this);
    } catch (e) {
      return defaultValue;
    }
  }

  Map? toMap([Map? defaultValue]) {
    try {
      return json.decode(this);
    } catch (e) {
      return defaultValue;
    }
  }

  Map<String, List<String>> splitQuery({Encoding encoding = utf8}) {
    return split("&").fold({}, (map, element) {
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
