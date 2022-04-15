part of cruky.handlers.in_direct;

const cjson = _JsonBind();

class JsonSchema {}

class _JsonBind {
  const _JsonBind();
}

bool _jsonValidType(ParameterMirror parameterMirror) {
  Type type = parameterMirror.type.reflectedType;
  Iterable list =
      parameterMirror.metadata.where((e) => e.reflectee is _JsonBind);
  if (list.isNotEmpty) return true;
  return type == Map ||
      parameterMirror.type.isSubtypeOf(reflectType(List)) ||
      parameterMirror.metadata
          .where((e) => e.reflectee is JsonSchema)
          .isNotEmpty;
}

class InJsonRoute extends BlankRoute {
  final ApplyMethod handler;
  final List<SchemaParam> schema;

  InJsonRoute({
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
    var json = await req.json();
    for (var item in schema) {
      if (item.bindFrom == BindFrom.query) {
        args.add(InQueryRoute.getQueryArg(req, item));
      } else if (item.bindFrom == BindFrom.json) {
        Iterable i = schema.where((e) => e.bindFrom == BindFrom.json);
        if (i.length == 1) {
          if (item.type.isSubtypeOf(reflectType(Map))) {
            if (json is Map) {
              args.add(Map.from(json));
              continue;
            } else {
              return Text(
                '"$json" is not subtype of map',
                422,
              );
            }
          } else if (item.type.isSubtypeOf(reflectType(List))) {
            if (json is List) {
              args.add(List.from(json));
              continue;
            } else {
              return Text(
                '"$json" is not subtype of list',
                422,
              );
            }
          }
        }
        json is Map;
        var data = json[item.name];
        if (data == null && !item.isOptional) {
          return Text('The field "${item.name}" is required', 422);
        }
        if (data is Map) {
          if (Map != item.type.reflectedType) {
            return Text(
              '"$data" is not subtype of ${getTypeName(item.type.reflectedType)}',
              422,
            );
          }
          args.add(Map.from(data));
          continue;
        }
        if (data is List) {
          if (List != item.type.reflectedType) {
            return Text(
              '"$data" is not subtype of ${getTypeName(item.type.reflectedType)}',
              422,
            );
          }
          args.add(List.from(data));
          continue;
        }
        if (item.type.reflectedType == num && (data is int || data is double)) {
          args.add(data);
          continue;
        } else if (data.runtimeType != item.type.reflectedType) {
          return Text(
            '"$data" is not subtype of ${getTypeName(item.type.reflectedType)}',
            422,
          );
        } else {
          args.add(data);
          continue;
        }
      }
    }
    var i = handler(args);
    if (i.reflectee is Future) return await i.reflectee;
    return i.reflectee;
  }
}
