part of cruky.handlers.in_direct;

const cform = _FormBind();

class FormSchema {}

class _FormBind {
  const _FormBind();
}

bool _formValidType(ParameterMirror parameterMirror) {
  Iterable list =
      parameterMirror.metadata.where((e) => e.reflectee is _FormBind);
  if (list.isNotEmpty) return true;
  return parameterMirror.metadata
      .where((e) => e.reflectee is JsonSchema)
      .isNotEmpty;
}

class InFormRoute extends BlankRoute {
  final ApplyMethod handler;
  final List<SchemaParam> schema;

  InFormRoute({
    required this.handler,
    required this.schema,
    required PathParser path,
    required List<String> methods,
    required List<MethodMW> beforeMW,
    required List<MethodMW> afterMW,
    required List<String> accepted,
  }) : super(
          accepted: accepted,
          methods: methods,
          path: path,
          beforeMW: beforeMW,
          afterMW: afterMW,
        );

  @override
  Future handle(ReqCTX req) async {
    List args = [];
    FormData form = await req.form();
    for (var item in schema) {
      if (item.bindFrom == BindFrom.query) {
        args.add(InQueryRoute.getQueryArg(req, item));
      } else if (item.bindFrom == BindFrom.form) {
        var data = form[item.name];
        if (data == null && !item.isOptional) {
          return Text('The field "${item.name}" is required', 422);
        }
        Object? arg;
        switch (item.type.reflectedType) {
          case int:
            arg = form.getInt(item.name);
            break;
          case double:
            arg = form.getDouble(item.name);
            break;
          case num:
            arg = form.getNum(item.name);
            break;
          case bool:
            arg = form.getBool(item.name);
            break;
          case List<String>:
            arg = data;
            break;
          case List:
            arg = data;
            break;
        }
        if (arg == null) {
          if (item.type.isSubtypeOf(reflectType(Map))) {
            args.add(form.getMap(item.name));
            continue;
          }
          return Text(
            '$data is not subtype of ${getTypeName(item.type.reflectedType)}',
            422,
          );
        }
        args.add(arg);
        continue;
      }
    }
    var i = handler(args);
    if (i.reflectee is Future) return await i.reflectee;
    return i.reflectee;
  }
}
