import 'dart:mirrors';

void main(List<String> args) {
  ClosureMirror mirror = reflect(name) as ClosureMirror;
  print(mirror.function.parameters.first.type.reflectedType);
}

class Data {
  const Data();
}

void name(@Data() int args) {}
