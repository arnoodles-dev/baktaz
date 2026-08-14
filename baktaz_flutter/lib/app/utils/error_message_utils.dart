import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

abstract final class ErrorMessageUtils {
  static String generate(BuildContext context, Failure failure) => switch (failure) {
    UnexpectedError(:final String? message) => message ?? 'An unexpected error occurred',
    ServerError(:final String? message) => message ?? 'A server error occurred',
    ServerpodError(:final String? message) => message ?? 'A connection error occurred',
    DeviceStorageError(:final String? message) => message ?? 'A storage error occurred',
    DeviceInfoError(:final String? message) => message ?? 'Device info error',
    AuthenticationError(:final String? message) => message ?? 'Authentication failed',
    SessionUnavailableError() => 'Session is unavailable',
    ValidationFailure(:final String value) => 'Validation error: $value',
    RemoteConfigError(:final String? message) => message ?? 'Configuration error',
  };
}
