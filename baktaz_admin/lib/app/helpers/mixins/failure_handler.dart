import 'package:baktaz_admin/app/helpers/mixins/error_actions.dart';
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
      case final ServerFailure error:
        actions.onServerError(error);
      case final DeviceStorageFailure error:
        actions.onDeviceRelatedError(error);
      case final DeviceInfoFailure error:
        actions.onDeviceRelatedError(error);
      case final ValidationFailure error:
        actions.onValidationError(error);
      case final AuthenticationFailure _:
      case final RemoteConfigFailure _:
      case final UnexpectedFailure _:
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
