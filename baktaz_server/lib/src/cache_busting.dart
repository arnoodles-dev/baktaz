import 'dart:io';

import 'package:serverpod/serverpod.dart';

/// Cache busting configuration.
/// Used in WidgetRoutes to cache-bust asset paths.
final CacheBustingConfig cacheBustingConfig = CacheBustingConfig(
  mountPrefix: '/web',
  fileSystemRoot: Directory(Uri(path: 'web/static').toFilePath()),
);
