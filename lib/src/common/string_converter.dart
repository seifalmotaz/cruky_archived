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
    if (this == "true") {
      return true;
    } else if (this == "false") {
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
}
