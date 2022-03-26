library cruco;

import 'package:logging/logging.dart';

export 'dart:io' show HttpStatus, HttpHeaders;

export './src/server/serve.dart';

export './src/annotiation.dart';
export '/src/server/server.dart';

export './src/interfaces/request/request.dart';
export './src/interfaces/file_part.dart';
export './src/interfaces/response.dart';

export './src/middleware.dart';

/// the logs for handling requests
final crukyLogger = Logger('CrukyRequestHandlers');
