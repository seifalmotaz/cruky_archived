library cruco;

import 'package:logging/logging.dart';

export 'dart:io' show HttpStatus, HttpHeaders;

export './src/serve.dart';

export './src/annotiation.dart';
export './src/server.dart';

export './src/interfaces/request/request.dart';
export './src/interfaces/file_part.dart';
export 'src/middleware.dart';

/// the logs for handling requests
final crukyLogger = Logger('CrukyRequestHandlers');

// TODO: adding headers to SimpleRequest
// TODO: adding global and private middlewares