library cruky.core.req;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cruky/src/common/string_converter.dart';
import 'package:cruky/src/request/file_part.dart';
import 'package:cruky/src/request/form_data.dart';
import 'package:mime/mime.dart';

class Request {
  final HttpRequest req;

  final MapConverter query;
  final MapConverter path;
  final Map<Symbol, Object> parser = {};

  HttpResponse get res => req.response;
  String get method => req.method;
  Uri get uri => req.uri;
  HttpSession get session => req.session;

  String? headerValue(String i) => req.headers.value(i);

  Map<String, List<String>> get headers {
    Map<String, List<String>> data = {};
    req.headers.forEach((name, values) {
      data.addAll({name: values});
    });
    return data;
  }

  Request({
    required this.req,
    required Map<String, dynamic> pathParams,
    required Map<String, dynamic> query,
  })  : path = MapConverter<Map<String, dynamic>>(pathParams),
        query = MapConverter<Map<String, dynamic>>(query);

  Future json() async {
    String string = await utf8.decodeStream(req);
    var body = string.isEmpty ? {} : jsonDecode(string);
    return body;
  }

  Future<Uint8List> _getBytes(HttpRequest request) {
    return request
        .fold<BytesBuilder>(BytesBuilder(copy: false), (a, b) => a..add(b))
        .then((b) => b.takeBytes());
  }

  Future<FormData> form() async {
    var bytes = await _getBytes(req);
    Map<String, List<String>> body = String.fromCharCodes(bytes).splitQuery();
    return FormData(body);
  }

  Future<iFormData> iForm() async {
    /// get the fields from multi form fields
    RegExp _matchName = RegExp('name=["|\'](.+)["|\']');
    RegExp _matchFileName = RegExp('filename=["|\'](.+)["|\']');

    final Map<String, String> formFields = {};
    final Map<String, List<FilePart>> formFiles = {};
    Stream<Uint8List> stream;

    var bytes = await _getBytes(req);
    var ctrl = StreamController<Uint8List>()
      ..add(bytes)
      ..close();
    stream = ctrl.stream;

    var parts = MimeMultipartTransformer(
            req.headers.contentType!.parameters['boundary']!)
        .bind(stream);

    await for (MimeMultipart part in parts) {
      String headers = part.headers['content-disposition']!;

      /// split headers fields
      List<String> headersFields = headers.split(';');

      /// get the name of form field
      String field = headersFields.firstWhere((e) => _matchName.hasMatch(e));
      RegExpMatch? fieldNameMatch = _matchName.firstMatch(field);

      /// check if the field name exist
      {
        if (fieldNameMatch == null) {
          throw {
            #status: 500,
            "msg": "Cannot find the header name field for the request",
          };
        }

        if (fieldNameMatch[1] == null) {
          throw {
            #status: 500,
            "msg": "the form field name is empty please "
                "try to put a name for the field",
          };
        }
      }

      String name = fieldNameMatch[1]!;

      /// check if this part is field or file
      if (!headers.contains('filename=')) {
        /// handle if if it's a field
        formFields[name] = await utf8.decodeStream(part);
        continue;
      }

      /// handle if it's file
      /// get file name from headers
      field = headersFields.firstWhere((e) => _matchFileName.hasMatch(e));
      RegExpMatch? fileNameMatch = _matchFileName.firstMatch(headers);

      /// check if the file name exist
      {
        if (fileNameMatch == null) {
          throw {
            #status: 500,
            "msg": "Cannot find the header name field for the request",
          };
        }

        if (fileNameMatch[1] == null) {
          throw {
            #status: 500,
            "msg": "the form field name is empty please "
                "try to put a name for the field",
          };
        }
      }

      String filename = fileNameMatch[1]!;

      /// add the file to formFiles as stream
      Stream<List<int>> streamBytes = part.asBroadcastStream();
      if (formFiles.containsKey(name)) {
        formFiles[name]!.add(FilePart(name, filename, streamBytes));
      } else {
        formFiles[name] = [FilePart(name, filename, streamBytes)];
      }
    }
    return iFormData(formFields, formFiles);
  }
}

class MapConverter<T extends Map> {
  final T data;
  MapConverter(this.data);

  String? get(String i) => data[i];

  dynamic getAny(String i) => data[i];

  int? getInt(String i) {
    final _data = data[i];
    if (_data == null) return null;
    return int.tryParse(_data);
  }

  double? getDouble(String i) {
    final _data = data[i];
    if (_data == null) return null;
    return double.tryParse(_data);
  }

  bool? getBool(String i) {
    final _data = data[i];
    if (_data == null) return null;
    String ii = _data.toLowerCase();
    if (ii.contains('true')) return true;
    if (ii.contains('false')) return false;
    return null;
  }
}
