import 'package:baktaz_flutter/app/helpers/mixins/error_actions.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:talker/talker.dart';

@lazySingleton
class FailureHandler with ErrorActions {
  FailureHandler(this._talker);

  final Talker _talker;

  void handleException(Exception error, StackTrace? stackTrace, [ErrorActions? errorActions]) {
    _talker.handle(error, stackTrace);
    handleFailure(Failure.unexpected(error.toString()), errorActions);
  }

  void handleFailure(Failure failure, [ErrorActions? errorActions]) {
    final ErrorActions actions = errorActions ?? this;

    switch (failure) {
      case final ServerError error:
        actions.onServerError(error);
      case final Failure error when error is DeviceStorageError || error is DeviceInfoError:
        actions.onDeviceRelatedError(error);
      case final ValidationFailure error:
        actions.onValidationError(error);
      case final RemoteConfigError error:
        actions.onRemoteConfigError(error);
      case final AuthenticationError error:
        actions.onAuthenticationError(error);
      default:
        actions.onGenericError(failure);
    }
  }

  Result<T> handleServerError<T>(StatusCode statusCode, Object? error) {
    if (error is ResourceErrorDTO) {
      return left(Failure.server(statusCode, error.message ?? error.toString()));
    }
    return left(Failure.server(statusCode, error?.toString() ?? 'Unknown error'));
  }
}
