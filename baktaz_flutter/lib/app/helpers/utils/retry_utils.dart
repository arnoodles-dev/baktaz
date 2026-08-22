import 'dart:async';
import 'dart:io';

abstract final class RetryUtils {
  static bool isRetryableException(Exception exception) =>
      exception is SocketException || exception is TimeoutException || exception is HttpException;
}
