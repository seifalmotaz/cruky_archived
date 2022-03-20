library cruky.handlers;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cruky/src/helper/path_regex.dart';
import 'package:cruky/src/interfaces/file_part.dart';
import 'package:cruky/src/interfaces/request/request.dart';
import 'package:mime/mime.dart';

part './method.dart';

/// get the fields from multi form fields
RegExp _matchName = RegExp('name=["|\'](.+)["|\']');
RegExp _matchFileName = RegExp('filename=["|\'](.+)["|\']');
