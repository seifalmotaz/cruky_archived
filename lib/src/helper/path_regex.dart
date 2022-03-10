RegExp parmRegExp = RegExp(r":[a-zA-Z]+\(?([^)]+)?\)?:?");
RegExp parmTypeRegExp = RegExp(r"\(([^)]*)\)");

/// Path data and regex
class PathRegex {
  /// path regex for matching
  final RegExp regExp;

  /// path params
  final List<ParamMap> params;
  PathRegex(this.regExp, this.params);

  /// match request path with this path
  bool match(String path) => regExp.hasMatch(path);

  /// get path parameters
  Map<Symbol, dynamic> parseParams(String path) {
    Map<Symbol, dynamic> _params = {};
    RegExpMatch paramsMatch = regExp.firstMatch(path)!;
    for (ParamMap param in params) {
      Symbol symbol = Symbol(param.name);
      String data = Uri.decodeQueryComponent(paramsMatch.group(param.index)!);
      if (param.type == String) _params.addAll({symbol: data});
      if (param.type == int) _params.addAll({symbol: int.parse(data)});
      if (param.type == double) _params.addAll({symbol: double.parse(data)});
    }
    return _params;
  }
}

/// Param info
class ParamMap {
  /// param name
  String name;

  /// param index in path params list
  int index;

  /// param type
  Type type;
  ParamMap(this.name, this.type, this.index);
}

/// get the path regex and parameters
/// return PathRegex
PathRegex pathRegEx(
  String path, {
  bool startWith = true,
  bool endWith = false,
}) {
  // define regex string and path parameters (parms)
  String regex = startWith ? r"^" : "";
  // params has list of ParamMap
  final List<ParamMap> params = [];

  // split path with "/" and remove the empty strings
  List<String> split = path.split('/');
  split.removeWhere((e) => e.isEmpty);

  int paramIndex = 0;

  // looping split to add every path slice to regex and
  // add parameters if exist
  for (var i = 0; i < split.length; i++) {
    // get the segmant
    String segmant = split[i];
    // check if the segmant is parameters
    if (!parmRegExp.hasMatch(segmant)) {
      // segmant does not have any parameters
      // so we add to regex as it is
      if (!segmant.startsWith('/')) regex += '/';
      regex += segmant;
    } else {
      late Type paramType;
      // segmant have a parameter
      // get the parameter data
      String param = parmRegExp.firstMatch(segmant)!.group(0)!; // the parameter

      String? type = parmTypeRegExp // parameter type (int, string, ..etc)
          .firstMatch(param)
          ?.group(0);

      String name = segmant // parameter name
          .replaceFirst(type ?? '', '')
          .replaceAll(':', '');

      // add "/" if it does not exist
      if (!param.startsWith('/')) regex += '/';
      // check parameter type and add the regex
      if (type == null || type == '(string)') {
        paramType = String;
        regex += r"([a-zA-Z0-9_-]+)";
      } else {
        if (type == '(int)') {
          paramType = int;
          regex += r"([0-9]+)";
        }
        if (type == '(double)') {
          paramType = double;
          regex += r"([^\s][0-9]*\.[0-9]+)";
        }
      }
      //backreference to regex group #1
      // regex += r'\' + (i + 1).toString();
      // add the parameter to params
      paramIndex++;
      params.add(ParamMap(name, paramType, paramIndex));
    }
  }

  // add last regex to path regex
  regex += endWith ? r'/?$' : "/?";
  return PathRegex(RegExp(regex, caseSensitive: false), params);
}
