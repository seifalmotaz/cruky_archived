void main(List<String> args) {
  Map t = _normalize('/todos/create/:hellow/:id');
  print((t['regexp'] as RegExp).pattern);
  print((t['keys']));
  print(_parseParams('/todos/create/task/1', t));
}

Map<String, String> _parseParams(String path, Map routePath) {
  Map<String, String> params = {};
  Match paramsMatch = routePath['regexp'].firstMatch(path);
  for (var i = 0; i < routePath['keys'].length; i++) {
    String param;
    try {
      param = Uri.decodeQueryComponent(paramsMatch[i + 1]!);
    } catch (e) {
      param = paramsMatch[i + 1]!;
    }

    params[routePath['keys'][i]] = param;
  }
  return params;
}

Map _normalize(dynamic path, {List<String>? keys, bool strict = false}) {
  keys ??= [];

  if (path is RegExp) {
    return {'regexp': path, 'keys': keys};
  }
  if (path is List) {
    path = '(${path.join('|')})';
  }

  if (!strict) {
    path += '/?';
  }

  path =
      path.replaceAllMapped(RegExp(r'(\.)?:(\w+)(\?)?'), (Match placeholder) {
    var replace = StringBuffer('(?:');

    if (placeholder[1] != null) {
      replace.write('.');
    }

    replace.write('([\\w%+-._~!\$&\'()*,;=:@]+))');

    if (placeholder[3] != null) {
      replace.write('?');
    }

    keys!.add(placeholder[2]!);

    return replace.toString();
  }).replaceAll('//', '/');

  return {'regexp': RegExp('^$path\$'), 'keys': keys};
}
