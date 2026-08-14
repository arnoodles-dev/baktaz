import 'package:baktaz_shared/baktaz_shared.dart';

abstract interface class IDeviceInfoRepository {
  TaskResult<String> getPhoneModel();

  TaskResult<(String, String)> getPhoneOSVersion();

  Result<String> getAppVersion();

  Result<String> getBuildNumber();
}
