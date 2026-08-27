import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

abstract final class ErrorMessageUtils {
  static String generate(BuildContext context, Failure failure) => switch (failure) {
    UnexpectedFailure(:final String? message) => message ?? 'An unexpected error occurred',
    ServerFailure(:final String? message) => message ?? 'A server error occurred',
    DeviceStorageFailure(:final String? message) => message ?? 'A storage error occurred',
    DeviceInfoFailure(:final String? message) => message ?? 'Device info error',
    AuthenticationFailure(:final String? message) => message ?? 'Authentication failed',
    ValidationFailure(:final String value) => 'Validation error: $value',
    RemoteConfigFailure(:final String? message) => message ?? 'Configuration error',
  };
}
