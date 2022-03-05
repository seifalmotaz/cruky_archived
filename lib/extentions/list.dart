extension ListExtraFunctions on List {
  dynamic pop() {
    dynamic i = last;
    removeLast();
    return i;
  }
}
