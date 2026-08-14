import 'dart:async' show TimeoutException;
import 'dart:io' show SocketException;

import 'package:flutter/services.dart' show PlatformException;

extension ExceptionExt on Exception {
  bool get isSocketException => this is SocketException;

  bool get isTimeoutException => this is TimeoutException;

  bool get isSignInFailedException => this is PlatformException && (this as PlatformException).code == 'sign_in_failed';
}
