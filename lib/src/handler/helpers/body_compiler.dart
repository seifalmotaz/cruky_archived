import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cruky/cruky.dart';
import 'package:cruky/src/helper/path_regex.dart';
import 'package:mime/mime.dart';

/// get the fields from multi form fields
RegExp _matchName = RegExp('name=["|\'](.+)["|\']');
RegExp _matchFileName = RegExp('filename=["|\'](.+)["|\']');

class BodyCompiler {
  static SimpleRequest simple(HttpRequest request, PathRegex path) =>
      SimpleRequest(
        path: request.uri,
        query: request.uri.queryParametersAll,
        parameters: path.parseParams(request.uri.path),
      );

  static Future<JsonRequest> json(HttpRequest request, PathRegex path) async {
    String string = await utf8.decodeStream(request);
    Map body = string.isEmpty ? {} : jsonDecode(string);
    return JsonRequest(
      body: body,
      path: request.uri,
      query: request.uri.queryParametersAll,
      parameters: path.parseParams(request.uri.path),
    );
  }

  static Future<Uint8List> _getBytes(HttpRequest request) {
    return request
        .fold<BytesBuilder>(BytesBuilder(copy: false), (a, b) => a..add(b))
        .then((b) => b.takeBytes());
  }

  static Future<FormRequest> form(HttpRequest request, PathRegex path) async {
    var bytes = await _getBytes(request);

    Map<String, String> body =
        Uri.splitQueryString(String.fromCharCodes(bytes));
    return FormRequest(
      parameters: path.parseParams(request.uri.path),
      path: request.uri,
      query: request.uri.queryParametersAll,
      form: body,
    );
  }

  static Future<iFormRequest> iForm(HttpRequest request, PathRegex path) async {
    final Map<String, String> formFields = {};
    final Map<String, FilePart> formFiles = {};
    Stream<Uint8List> stream;

    var bytes = await _getBytes(request);
    var ctrl = StreamController<Uint8List>()
      ..add(bytes)
      ..close();
    stream = ctrl.stream;

    var parts = MimeMultipartTransformer(
            request.headers.contentType!.parameters['boundary']!)
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
      formFiles[name] = FilePart(name, filename, streamBytes);
    }

    return iFormRequest(
      form: formFields,
      files: formFiles,
      path: request.uri,
      query: request.uri.queryParametersAll,
      parameters: path.parseParams(request.uri.path),
    );
  }
}
