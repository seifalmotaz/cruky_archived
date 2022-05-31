library cruky.core.req;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cruky/cruky.dart';
import 'package:cruky/src/common/string_converter.dart';
import 'package:mime/mime.dart';

import 'common/query.dart';

/// request manipulating helper
class Request {
  /// native [HttpRequest] class from the stream listener
  final HttpRequest native;

  /// request query
  final QueryParameters query;

  /// request path parameters
  final Map<String, dynamic> pathParams;

  /// native [HttpResponse] class from [HttpRequest]
  HttpResponse get res => native.response;

  /// request method
  String get method => native.method;

  /// request uri
  Uri get uri => native.uri;

  /// request headers content type
  ContentType? get contentType => native.headers.contentType;

  /// request session
  HttpSession get session => native.session;

  /// request client info
  HttpConnectionInfo? get client => native.connectionInfo;

  /// [HttpRequest] headers
  HttpHeaders get headers => native.headers;

  /// request manipulating helper
  Request({
    required this.pathParams,
    required this.native,
  }) : query = QueryParameters(native.uri);

  /// just parsing the [HttpRequest]
  Request.pass(this.native)
      : pathParams = {},
        query = QueryParameters(native.uri);

  /// data that passed from the pipeline/middleware
  final Map<Symbol, Object> parser = {};

  Future<Uint8List> body() async {
    BytesBuilder bytesBuilder = await native.fold<BytesBuilder>(
        BytesBuilder(copy: false), (a, b) => a..add(b));
    return bytesBuilder.takeBytes();
  }

  Stream<Uint8List> bodyStream() {
    return native.asBroadcastStream();
  }

  /// covert request body to json/map it can return map or list
  Future json() async {
    String string = await utf8.decodeStream(native);
    var body = string.isEmpty ? {} : jsonDecode(string);
    return body;
  }

  /// covert request body to form data
  Future<FormData> form() async {
    var bytes = await body();
    Map<String, List<String>> value = String.fromCharCodes(bytes).splitQuery();
    return FormData(value);
  }

  /// covert request body to multipart form data
  Future<iFormData> iForm() async {
    final Map<String, List<String>> formFields = {};
    final Map<String, List<FilePart>> formFiles = {};

    Stream<Uint8List> stream = bodyStream();

    if (contentType == null) {
      throw ExpRes.e415().exp();
    }
    if (contentType!.parameters['boundary'] == null) {
      throw ExpRes.e400("`boundary` not found in headers").exp();
    }

    late Stream<MimeMultipart> parts;
    try {
      parts = MimeMultipartTransformer(contentType!.parameters['boundary']!)
          .bind(stream);
    } catch (e) {
      throw ExpRes.e400(e.toString()).exp();
    }

    await for (MimeMultipart part in parts) {
      Map<String, String?> parameters;
      {
        final String contentDisposition = part.headers['content-disposition']!;
        parameters = ContentType.parse(contentDisposition).parameters;
      }

      /// get the name of form field
      String? name = parameters['name'];

      /// check if the field name exist
      if (name == null) {
        throw ExpRes.e400(
          "Cannot find the header name field for the request content",
        ).exp();
      }

      /// check if this part is field or file
      if (!parameters.containsKey('filename')) {
        if (formFields.containsKey(name)) {
          formFields[name]!.add(await utf8.decodeStream(part));
        } else {
          formFields[name] = [await utf8.decodeStream(part)];
        }
        continue;
      }

      /// ================ handle if it's file =====================
      String? filename = parameters['filename'];
      if (filename == null) {
        throw ExpRes.e400("Cannot find the header name field for the request")
            .exp();
      }

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
