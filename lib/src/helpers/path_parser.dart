import 'package:cruky/src/utils/utils.dart';

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

/// Path data and regex
class PathParser {
  /// native path
  final String path;

  /// path regex for matching
  final RegExp regExp;

  /// path params
  final List<ParamMap> params;

  /// init
  PathParser(this.regExp, this.params, this.path);

  /// match request path with this path
  bool match(String path) => regExp.hasMatch(path);

  PathParser addPrefix(
    String p, {
    bool startWith = true,
    bool endWith = false,
  }) {
    List list = p.split('/') + path.split('/');
    String full = list.join('/');
    return PathParser.parse(
      full,
      startWith: startWith,
      endWith: endWith,
    );
  }

  /// get path parameters
  Map<String, dynamic> parseParams(String path) {
    Map<String, dynamic> _params = {};
    RegExpMatch paramsMatch = regExp.firstMatch(path)!;
    for (ParamMap param in params) {
      String symbol = param.name;
      String data = Uri.decodeQueryComponent(paramsMatch.group(param.index)!);

      if (param.type == String) {
        _params.addAll({symbol: data});
        continue;
      }

      if (param.type == int) {
        _params.addAll({symbol: data.toInt()});
        continue;
      }

      if (param.type == double) {
        _params.addAll({symbol: data.toDouble()});
        continue;
      }

      if (param.type == num) {
        _params.addAll({symbol: data.toNum()});
        continue;
      }
    }
    return _params;
  }

  /// get the path regex and parameters
  /// return PathRegex
  factory PathParser.parse(
    String path, {
    bool startWith = true,
    bool endWith = true,
  }) {
    List<String> list = path.split('/')..removeWhere((e) => e.isEmpty);
    path = list.join('/');

    /// path arguments regex
    final RegExp parmRegExp = RegExp(r":[a-zA-Z]+\(?([^)]+)?\)?");

    // define regex string and path parameters (parms)
    String regex = startWith ? r"^/" : "/";
    regex += path;

    // params has list of ParamMap
    final List<ParamMap> params = [];

    int paramIndex = 0;

    regex = regex.replaceAllMapped(parmRegExp, (match) {
      late Type paramType;
      String _regex = '';

      String param = match[0]!; // the parameter
      String? type = match[1]; // the parameter type

      String name = param.substring(
          1, type == null ? param.length - 1 : param.indexOf('('),);
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
    regex += endWith ? r'/?$' : "/?";
    if (!path.startsWith('/')) path += '/';
    if (!path.endsWith('/')) path = '/' + path;
    return PathParser(RegExp(regex, caseSensitive: false), params, path);
  }
}
