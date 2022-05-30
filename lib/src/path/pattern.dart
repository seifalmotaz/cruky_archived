library cruky.path.pattern;

import 'package:cruky/src/common/string_converter.dart';

class PathPattern {
  /// the native path fro [Route] class
  final String path;

  final List<ParameterInfo> parameters;

  /// Regular Expression path for matching request paths
  final RegExp regExp;
  const PathPattern(this.path, this.parameters, this.regExp);

  bool match(String reqPath) {
    reqPath = reqPath.replaceAll(r'\', "/");
    final RegExpMatch? expMatch = regExp.firstMatch(reqPath);
    if (expMatch == null) return false;
    return true;
  }

  /// map the parameters from request uri.path
  Map<String, dynamic> parse(String reqPath) {
    final RegExpMatch expMatch = regExp.firstMatch(reqPath)!;
    final Map<String, dynamic> data = {};
    for (ParameterInfo parameter in parameters) {
      final String value =
          Uri.decodeQueryComponent(expMatch.group(parameter.groupIndex)!);

      if (parameter.type == String) {
        data.addAll({parameter.name: value});
        continue;
      }

      if (parameter.type == int) {
        data.addAll({parameter.name: value.toInt()});
        continue;
      }

      if (parameter.type == double) {
        data.addAll({parameter.name: value.toDouble()});
        continue;
      }

      if (parameter.type == num) {
        data.addAll({parameter.name: value.toNum()});
        continue;
      }
    }
    return data;
  }

  /// from [Route] path to PathPattern class
  factory PathPattern.parse(String path) {
    path = (path.split('/')..removeWhere((e) => e.isEmpty)).join('/');
    path = "/$path";

    final List<ParameterInfo> parameters = [];

    /// path arguments regex
    final RegExp paramRegExp = RegExp(r":[a-zA-Z]+\(?([^)]+)?\)?:?");

    int groupIndex = 0;
    String regex = path.replaceAllMapped(paramRegExp, (match) {
      Type dartType;
      String parameterRegExp = '';

      final String? type = match[1]; // parameter type

      String name;
      {
        final int i =
            type == null ? match[0]!.length - 1 : match[0]!.indexOf('(');
        name = match[0]!.substring(1, i);
      }

      // check parameter type and add the regex
      if (type == null || type == 'string') {
        dartType = String;
        parameterRegExp += r"([^\/]+)";
      } else {
        if (type == 'int') {
          dartType = int;
          parameterRegExp += r"([0-9]+)";
        } else if (type == 'double') {
          dartType = double;
          parameterRegExp += r"([0-9]*\.[0-9]+)";
        } else if (type == 'num') {
          dartType = num;
          parameterRegExp += r"([0-9]*(\.[0-9]+)?)";
        } else if (type == 'path') {
          dartType = String;
          parameterRegExp += "(.+)";
        } else if (type.startsWith(r'\')) {
          dartType = String;
          parameterRegExp += "(${type.substring(1)})";
        } else {
          dartType = String;
          parameterRegExp += r"([^\/]+)";
        }
      }

      groupIndex++;
      parameters.add(ParameterInfo(name, dartType, groupIndex));
      return parameterRegExp;
    });
    regex += r'\/?';
    return PathPattern(path, parameters, RegExp(regex));
  }
}

/// Param info
class ParameterInfo {
  /// param name
  final String name;

  /// param index in path params list
  final int groupIndex;

  /// param type
  final Type type;
  ParameterInfo(this.name, this.type, this.groupIndex);
}
