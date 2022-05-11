import 'package:cruky/src/common/string_converter.dart';

/// Param info
class ParamInfo {
  /// param name
  final String name;

  /// param index in path params list
  final int seg;
  final int groupInt;

  /// param type
  final Type type;
  ParamInfo(this.name, this.type, this.seg, this.groupInt);
}

/// Path data and regex
class PathPattern {
  final bool isAbstract;

  /// path regex for matching
  final Map<RegExp, List<ParamInfo>> segmants;

  /// Path data and regex
  PathPattern(this.segmants, this.isAbstract);

  bool matchSeg(String seg, int i) {
    try {
      RegExp reg = segmants.keys.toList()[i];
      if (reg.firstMatch(seg) != null) return true;
      return false;
    } on RangeError {
      return false;
    }
  }

  /// match request path with this path
  bool match(List<String> pathSegmants) {
    pathSegmants = List.of(pathSegmants)..removeWhere((e) => e.isEmpty);
    List<MapEntry<RegExp, List<ParamInfo>>> entries = segmants.entries.toList();
    if (!isAbstract) {
      if (pathSegmants.length != entries.length) return false;
      for (var i = 0; i < pathSegmants.length; i++) {
        MapEntry<RegExp, List<ParamInfo>> entry = entries[i];
        String seg = pathSegmants[i];

        RegExpMatch? match = entry.key.firstMatch(seg);
        if (match == null) return false;
      }
    } else {
      for (var i = 0; i < entries.length; i++) {
        MapEntry<RegExp, List<ParamInfo>> entry = entries[i];
        String seg = pathSegmants[i];

        RegExpMatch? match = entry.key.firstMatch(seg);
        if (match == null) return false;
      }
    }
    return true;
  }

  /// get regex
  RegExpMatch regex(List<String> pathSegmants) {
    pathSegmants = List.of(pathSegmants)..removeWhere((e) => e.isEmpty);
    String path = pathSegmants.join('/');
    String fullRegex = segmants.keys.map((e) => e.pattern).join('/');
    return RegExp(fullRegex).firstMatch(path)!;
  }

  /// get path parameters
  Map<String, dynamic> parseParams(String path) {
    Map<String, dynamic> _params = {};
    for (var seg in segmants.entries) {
      RegExpMatch paramsMatch = seg.key.firstMatch(path)!;
      for (ParamInfo param in seg.value) {
        String symbol = param.name;
        String data =
            Uri.decodeQueryComponent(paramsMatch.group(param.groupInt)!);

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
    }
    return _params;
  }

  /// get the path regex and parameters
  /// return PathPattern
  factory PathPattern.parse(
    String path, {
    bool startWith = true,
    bool endWith = true,
  }) {
    List<String> list = path.split('/')..removeWhere((e) => e.isEmpty);

    final Map<RegExp, List<ParamInfo>> fSegmants = {}; // the final segmants

    /// path arguments regex
    final RegExp parmRegExp = RegExp(r":[a-zA-Z]+\(?([^)]+)?\)?:?");

    for (var i = 0; i < list.length; i++) {
      String seg = list[i];
      int paramIndex = 0;

      // params has list of ParamInfo
      final List<ParamInfo> params = [];

      ///
      String regex = seg.replaceAllMapped(parmRegExp, (Match match) {
        late Type paramType;
        String _regex = '';

        String param = match[0]!; // the parameter
        String? type = match[1]; // the parameter type

        String name = param.substring(
          1,
          type == null ? param.length - 1 : param.indexOf('('),
        );
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
            _regex += r"([0-9]*\.[0-9]+)";
          }
          if (type == 'num') {
            paramType = num;
            _regex += r"([0-9]*(\.[0-9]+)?)";
          }
        }

        paramIndex++;
        params.add(ParamInfo(name, paramType, i, paramIndex));
        return _regex;
      });

      fSegmants.addAll({RegExp(regex): params});
    }
    String last;
    try {
      last = list.last;
    } catch (e) {
      last = '';
    }
    if (last == '.*' || last == '.+' || last == '(.+)' || last == '(.*)') {
      return PathPattern(fSegmants, true);
    } else {
      return PathPattern(fSegmants, false);
    }
  }
}
