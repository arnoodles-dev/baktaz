import 'package:baktaz_shared/src/entity/enum/status_code.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trust_but_verify/trust_but_verify.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure implements Exception {
  const factory Failure.unexpected(String? message) = UnexpectedFailure;

  const factory Failure.server(StatusCode code, String? message) = ServerFailure;

  const factory Failure.deviceStorage(String? message) = DeviceStorageFailure;

  const factory Failure.deviceInfo(String? message) = DeviceInfoFailure;

  const factory Failure.authentication(String? message, {@Default(false) bool blocked}) = AuthenticationFailure;

  const factory Failure.validation(ValidationError error, String value) = ValidationFailure;

  const factory Failure.remoteConfig(String? message) = RemoteConfigFailure;

  const Failure._();

  String? get message => mapOrNull(
    unexpected: (UnexpectedFailure error) => error.message,
    server: (ServerFailure error) => error.message,
    deviceStorage: (DeviceStorageFailure error) => error.message,
    deviceInfo: (DeviceInfoFailure error) => error.message,
    authentication: (AuthenticationFailure error) => error.message,
    validation: (ValidationFailure failure) => '${failure.value}: ${failure.error.message}',
    remoteConfig: (RemoteConfigFailure error) => error.message,
  );
}
