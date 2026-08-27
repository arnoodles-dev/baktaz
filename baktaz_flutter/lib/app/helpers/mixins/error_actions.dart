import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/utils/dialog_utils.dart';
import 'package:baktaz_flutter/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/foundation.dart';
import 'package:toastification/toastification.dart';

mixin ErrorActions {
  I18n get _localization => getIt<AppLocalizationCubit>().stateValue;
  ToastificationItem? _activeToast;

  void _showErrorOnce(String message) {
    if (_activeToast?.isRunning ?? false) return;
    _activeToast = DialogUtils.showError(message);
  }

  void onServerError(ServerFailure error) {
    _showErrorOnce(error.message ?? _localization.common.error.generic);
  }

  void onDeviceRelatedError(Failure error) {
    final String? message = switch (error) {
      DeviceStorageFailure(:final String? message) => message,
      DeviceInfoFailure(:final String? message) => message,
      _ => null,
    };
    _showErrorOnce(message ?? _localization.common.error.generic);
  }

  void onValidationError(ValidationFailure error) {
    _showErrorOnce(error.message ?? _localization.common.error.generic);
  }

  void onAuthenticationError(AuthenticationFailure error) {
    _showErrorOnce(error.message ?? _localization.common.error.generic);
  }

  void onRemoteConfigError(RemoteConfigFailure error) {
    _showErrorOnce(error.message ?? _localization.common.error.generic);
  }

  void onGenericError(Failure error) {
    final String message = error is UnexpectedFailure && kDebugMode
        ? error.message ?? _localization.common.error.generic
        : _localization.common.error.generic;
    _showErrorOnce(message);
  }
}
