part of cruky.handlers.in_direct;

const query = _QueryBind();

class _QueryBind {
  const _QueryBind();
}

bool _queryValidType(TypeMirror typeMirror) {
  Type type = typeMirror.reflectedType;
  return type == String ||
      type == int ||
      type == double ||
      type == bool ||
      type == num;
}

class InQueryRoute extends BlankRoute {
  final ApplyMethod handler;
  final List<SchemaParam> schema;

  InQueryRoute({
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

  static Object? getQueryArg(ReqCTX req, SchemaParam item) {
    var data = req.query[item.name];
    if (data == null) {
      if (!item.isOptional) {
        throw Text('The field "${item.name}" is required', 422);
      } else {
        data;
      }
    }

    if (item.type.isSubtypeOf(reflectType(List))) {
      return DataConverter.transformList(
        data!,
        item.type.reflectedType,
      );
    } else {
      return DataConverter.transformListToType(
        data!,
        item.type.reflectedType,
      );
    }
  }

  @override
  Future handle(ReqCTX req) async {
    List args = [];
    for (var item in schema) {
      if (item.bindFrom == BindFrom.query) args.add(getQueryArg(req, item));
    }
    var i = handler(args);
    if (i.reflectee is Future) return await i.reflectee;
    return i.reflectee;
  }
}
