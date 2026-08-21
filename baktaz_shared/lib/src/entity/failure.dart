import 'package:baktaz_shared/src/entity/enum/status_code.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trust_but_verify/trust_but_verify.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure implements Exception {
  const factory Failure.unexpected(String? message) = UnexpectedError;

  const factory Failure.server(StatusCode code, String? message) = ServerError;

  const factory Failure.serverpod(String? message) = ServerpodError;

  const factory Failure.deviceStorage(String? message) = DeviceStorageError;

  const factory Failure.deviceInfo(String? message) = DeviceInfoError;

  const factory Failure.authentication(String? message, {@Default(false) bool blocked}) = AuthenticationError;

  const factory Failure.sessionUnavailable() = SessionUnavailableError;

  const factory Failure.validation(ValidationError error, String value) = ValidationFailure;

  const factory Failure.remoteConfig(String? message) = RemoteConfigError;

  const Failure._();

  String? get message => mapOrNull(
    unexpected: (UnexpectedError error) => error.message,
    server: (ServerError error) => error.message,
    serverpod: (ServerpodError error) => error.message,
    deviceStorage: (DeviceStorageError error) => error.message,
    deviceInfo: (DeviceInfoError error) => error.message,
    authentication: (AuthenticationError error) => error.message,
    validation: (ValidationFailure failure) => '${failure.value}: ${failure.error.message}',
    remoteConfig: (RemoteConfigError error) => error.message,
  );
}
