library cruco;

import 'package:logging/logging.dart';

export 'dart:io' show HttpStatus;

export './src/serve.dart';

export './src/annotiation.dart';
export './src/server.dart';

export './src/interfaces/request/request.dart';
export './src/interfaces/file_part.dart';

/// the logs for handling requests
final crukyLogger = Logger('CrukyRequestHandlers');
