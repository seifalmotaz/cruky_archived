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
  Map<String, dynamic> parseParams(String path) {
    Map<String, dynamic> _params = {};
    RegExpMatch paramsMatch = regExp.firstMatch(path)!;
    for (ParamMap param in params) {
      String symbol = param.name;
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
  if (!path.startsWith('/')) path += '/';
  regex += path;

  // params has list of ParamMap
  final List<ParamMap> params = [];

  int paramIndex = 0;

  regex = regex.replaceAllMapped(parmRegExp, (match) {
    late Type paramType;
    String _regex = '';

    String param = match[0]!; // the parameter
    String? type = match[1]; // the parameter type

    String name = param.substring(1, param.indexOf('('));
    // check parameter type and add the regex
    if (type == null || type == 'string') {
      paramType = String;
      _regex += r"([a-zA-Z0-9_-]+)";
    } else {
      if (type == 'int') {
        paramType = int;
        _regex += r"([0-9]+)";
      }
      if (type == 'double') {
        paramType = double;
        _regex += r"([^\s][0-9]*\.[0-9]+)";
      }
    }

    paramIndex++;
    params.add(ParamMap(name, paramType, paramIndex));
    return _regex;
  });

  /// ending regex
  if (regex.endsWith('/')) {
    regex += endWith ? r'?$' : "?";
  } else {
    regex += endWith ? r'/?$' : "/?";
  }

  return PathRegex(RegExp(regex, caseSensitive: false), params);
}
