import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ILocalStorageRepository {
  TaskResult<String?> getAccessToken();
  TaskResult<Unit> setAccessToken(String accessToken);
  TaskResult<Unit> deleteAccessToken();

  TaskResult<String?> getRefreshToken();
  TaskResult<Unit> setRefreshToken(String refreshToken);
  TaskResult<Unit> deleteRefreshToken();

  TaskResult<bool?> getIsOnboardingDone();
  TaskResult<Unit> setIsOnboardingDone();

  TaskResult<bool?> getIsDarkMode();
  TaskResult<Unit> setIsDarkMode({required bool isDarkMode});

  TaskResult<int?> getOtaLocalizationVersion();
  TaskResult<Unit> setOtaLocalizationVersion(int version);

  TaskResult<String?> getOtaLocalizationOverrides();
  TaskResult<Unit> setOtaLocalizationOverrides(String jsonString);
}
