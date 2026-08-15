// ignore_for_file: prefer-match-file-name, depend_on_referenced_packages

import 'package:baktaz_admin/app/constants/constant.dart';
import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../flutter_test_config.dart';
import 'generated_mocks.mocks.dart';
import 'mock_path_provider_platform.dart';

Future<void> setupInjection() async {
  await getIt.reset();
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = MockPathProviderPlatform();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  _mockPackageInfo();
  await Future.wait(<Future<void>>[configureDependencies(Env.test)]);
  getIt.registerLazySingleton(MockServerpod.new);
}

void _mockPackageInfo() {
  PackageInfo.setMockInitialValues(
    appName: Constant.appName,
    packageName: 'com.example.example',
    version: '1.0',
    buildNumber: '1',
    buildSignature: 'buildSignature',
  );
}

extension FileNameX on String {
  String get goldensVersion => '${this}_${TestConfig.goldensVersion}';
}

final Account mockAccount = Account(
  id: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
  authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
  userProfileId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
  userInfoId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
  walletId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
  userProfile: UserProfile(
    authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
    userName: 'admin',
    fullName: 'Admin User',
    email: 'admin@baktaz.com',
  ),
);
