extension BoolParsing on String {
  bool parseBool() {
    String s = replaceAll(' ', '');
    if (s.toLowerCase() == 'true') {
      return true;
    } else if (s.toLowerCase() == 'false') {
      return false;
    }

    throw '"$this" can not be parsed to boolean.';
  }
}
