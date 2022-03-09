class PathRegEx {
  String regExp;
  Map<String, int> parms;
  PathRegEx(this.regExp, this.parms);

  match(String path) => RegExp(regExp).hasMatch(path);

  String? getKey(Symbol key, String path) {
    List<String> split = path.split('/');
    split.removeWhere((e) => e.isEmpty);
    List<String> keys = parms.keys.toList();
    List<int> values = parms.values.toList();
    for (var i = 0; i < parms.length; i++) {
      if (Symbol(keys[i]) != key) continue;
      return split[values[i]];
    }
    return null;
  }
}

PathRegEx pathRegEx(String path, {String? startWith, String? endWith}) {
  PathRegEx regex = PathRegEx(startWith ?? "^", {});
  List<String> split = path.split('/');
  split.removeWhere((e) => e.isEmpty);
  RegExp parmRegExp = RegExp(r":[a-zA-Z]+\(?([^)]+)?\)?:?");
  RegExp parmTypeRegExp = RegExp(r"\(([^)]*)\)");
  for (var i = 0; i < split.length; i++) {
    String segmant = split[i];
    if (!parmRegExp.hasMatch(segmant)) {
      if (!segmant.startsWith('/')) regex.regExp += '/';
      regex.regExp += segmant;
    } else {
      String parm = parmRegExp.firstMatch(segmant)!.group(0)!;
      String? type = parmTypeRegExp.firstMatch(parm)?.group(0);
      String name = segmant.replaceFirst(type ?? '', '').replaceAll(':', '');

      if (!parm.startsWith('/')) regex.regExp += '/';
      if (type == null) regex.regExp += r"[a-zA-Z0-9_-]+";
      if (type == '(int)') regex.regExp += r"[0-9]+";
      if (type == '(string)') regex.regExp += r"[^0-9]+";
      if (type == '(double)') regex.regExp += r"[0-9]*.[0-9]+";
      regex.parms.addAll({name: i});
    }
  }
  regex.regExp += endWith ?? r'/?$';
  return regex;
}
