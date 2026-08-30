# RemoteConfig Server Infrastructure & Client Fetch Implementation Plan

> **Parent Canonical Roadmap:** Governed by and aligned with the Master Integration Plan in [`/Users/Arnold/Projects/baktaz/docs/superpowers/plans/2026-08-30-master-integration-plan.md`](../2026-08-30-master-integration-plan.md).
> All models, paths, and invariants (Serverpod 2.x `remote_config` feature module structure, RAM targeting engine evaluation with L1 `session.caches.local` caching, `ServerpodRemoteConfigService` implementing `IRemoteConfigService`, boundary RPC input validation, Pattern B error handling, `TaskResult<T>` repository returns, and implementation-first testing workflows) strictly conform to the master roadmap.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Serverpod backend infrastructure for RemoteConfig (models, targeting evaluation engine, caching, seeder, public endpoint) and integrate `baktaz_flutter`'s `RemoteConfigCubit` with `baktaz_client`.

**Architecture:** Serverpod 2.x feature module `remote_config` with entity splitting (`ConfigKey`, `TargetingOverride`, `ConfigSnapshotVersion`, `RemoteConfigValueType`) and transient DTOs (`RemoteConfig`, `PublicConfigVersion`, `RemoteConfigValue`, `RemoteConfigDefaultValue`). Evaluated in RAM with L1 `session.caches.local` caching. Flutter client uses `ServerpodRemoteConfigService` implementing `IRemoteConfigService` with injected `IDeviceInfoRepository`.

**Tech Stack:** Dart 3.x, Serverpod 2.x, Flutter, `pub_semver`, `crypto`, `get_it`, `injectable`, `bloc_signals`.

**Spec:** `docs/superpowers/specs/RemoteConfig/00-overview.md`

## Global Constraints

- Dart width: 120 chars
- PK format: `UuidValue?, defaultPersist=random` for persistent entities
- Foreign keys: `onDelete=Cascade`
- Enum location: `baktaz_server/lib/src/features/remote_config/domain/model/remote_config_value_type.spy.yaml`
- Interface location: `baktaz_server/lib/src/features/remote_config/domain/interface/i_remote_config_repository.dart`
- Repository location: `baktaz_server/lib/src/features/remote_config/data/repository/remote_config_repository.dart`
- Endpoint location: `baktaz_server/lib/src/features/remote_config/endpoint/remote_config_endpoint.dart`
- Client service location: `baktaz_flutter/lib/core/data/service/serverpod_remote_config_service.dart`

---

### Task 1: Create Serverpod Data Models & Enums (`baktaz_server`)

**Files:**
- Create: `baktaz_server/lib/src/features/remote_config/domain/model/remote_config_value_type.spy.yaml`
- Create: `baktaz_server/lib/src/features/remote_config/domain/model/config_key.spy.yaml`
- Create: `baktaz_server/lib/src/features/remote_config/domain/model/targeting_override.spy.yaml`
- Create: `baktaz_server/lib/src/features/remote_config/domain/model/config_snapshot_version.spy.yaml`
- Create: `baktaz_server/lib/src/features/remote_config/domain/model/public_config_version.spy.yaml`
- Create: `baktaz_server/lib/src/features/remote_config/domain/model/remote_config_default_value.spy.yaml`
- Create: `baktaz_server/lib/src/features/remote_config/domain/model/remote_config_value.spy.yaml`
- Create: `baktaz_server/lib/src/features/remote_config/domain/model/remote_config.spy.yaml`

**Interfaces:**
- Produces: `RemoteConfigValueType`, `ConfigKey`, `TargetingOverride`, `ConfigSnapshotVersion`, `PublicConfigVersion`, `RemoteConfigDefaultValue`, `RemoteConfigValue`, `RemoteConfig` generated Serverpod classes.

- [ ] **Step 1: Write `.spy.yaml` files**

Create `baktaz_server/lib/src/features/remote_config/domain/model/remote_config_value_type.spy.yaml`:
```yaml
enum: RemoteConfigValueType
values:
  - string
  - boolean
  - integer
  - double
  - json
```

Create `baktaz_server/lib/src/features/remote_config/domain/model/config_key.spy.yaml`:
```yaml
class: ConfigKey
table: config_key
fields:
  id: UuidValue?, defaultPersist=random
  key: String
  valueType: RemoteConfigValueType
  defaultValue: String
  description: String?
  createdAt: DateTime, default=now
  updatedAt: DateTime?, scope=serverOnly

indexes:
  config_key_key_unique_idx:
    fields: key
    unique: true
```

Create `baktaz_server/lib/src/features/remote_config/domain/model/targeting_override.spy.yaml`:
```yaml
class: TargetingOverride
table: targeting_override
fields:
  id: UuidValue?, defaultPersist=random
  configKeyId: UuidValue
  configKey: ConfigKey?, relation(field=configKeyId, onDelete=Cascade)
  priority: int
  appVersionConstraint: String?
  userTiers: List<String>?
  customSegmentValues: List<String>?
  rolloutPercentage: int?
  servedValue: String
  isActive: bool

indexes:
  targeting_override_priority_idx:
    fields: [configKeyId, priority]
```

Create `baktaz_server/lib/src/features/remote_config/domain/model/config_snapshot_version.spy.yaml`:
```yaml
class: ConfigSnapshotVersion
table: config_snapshot_version
fields:
  id: UuidValue?, defaultPersist=random
  versionNumber: String
  updateTime: DateTime, default=now
  updateUserEmail: String?
  updateOrigin: String?
  updateType: String?

indexes:
  config_version_number_idx:
    fields: versionNumber
    unique: true
```

Create `baktaz_server/lib/src/features/remote_config/domain/model/public_config_version.spy.yaml`:
```yaml
class: PublicConfigVersion
fields:
  versionNumber: String
  updateTime: DateTime
```

Create `baktaz_server/lib/src/features/remote_config/domain/model/remote_config_default_value.spy.yaml`:
```yaml
class: RemoteConfigDefaultValue
fields:
  value: String
```

Create `baktaz_server/lib/src/features/remote_config/domain/model/remote_config_value.spy.yaml`:
```yaml
class: RemoteConfigValue
fields:
  defaultValue: RemoteConfigDefaultValue
  valueType: RemoteConfigValueType
  value: String
```

Create `baktaz_server/lib/src/features/remote_config/domain/model/remote_config.spy.yaml`:
```yaml
class: RemoteConfig
fields:
  config: Map<String, RemoteConfigValue>
  version: PublicConfigVersion
```

- [ ] **Step 2: Generate Serverpod protocol files**

Run: `rtk dart run serverpod_cli generate` inside `baktaz_server/`
Expected: Success with `lib/src/generated/protocol.dart` updated.

- [ ] **Step 3: Commit**

```bash
git add baktaz_server/lib/src/features/remote_config/domain/model/ baktaz_server/lib/src/generated/ baktaz_client/
git commit -m "feat(remote_config): add Serverpod model and enum definitions"
```

---

### Task 2: Create Database Migration (`baktaz_server`)

**Files:**
- Create: Migration files in `baktaz_server/migrations/`

- [ ] **Step 1: Create migration**

Use tool `serverpod_create_migration`.
Expected: New migration folder created under `baktaz_server/migrations/`.

- [ ] **Step 2: Apply migration**

Use tool `serverpod_apply_migrations`.
Expected: Migrations applied successfully to PostgreSQL database.

- [ ] **Step 3: Commit**

```bash
git add baktaz_server/migrations/
git commit -m "feat(remote_config): add database migration for remote config tables"
```

---

### Task 3: Implement RemoteConfig Evaluation Engine & Repository (`baktaz_server`)

**Files:**
- Create: `baktaz_server/lib/src/features/remote_config/domain/interface/i_remote_config_repository.dart`
- Create: `baktaz_server/lib/src/features/remote_config/data/repository/remote_config_repository.dart`
- Create: `baktaz_server/test/unit/features/remote_config/remote_config_repository_test.dart`

**Interfaces:**
- Consumes: `ConfigKey`, `TargetingOverride`, `ConfigSnapshotVersion`, `RemoteConfig`, `RemoteConfigValueType` generated models.
- Produces: `IRemoteConfigRepository.evaluateConfig(Session session, ...)` returning `Future<RemoteConfig>`.

- [ ] **Step 1: Write the failing unit test**

Create `baktaz_server/test/unit/features/remote_config/remote_config_repository_test.dart`:
```dart
import 'package:baktaz_server/src/features/remote_config/data/repository/remote_config_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('RemoteConfigRepository Unit Tests', () {
    test('evaluateOverride returns servedValue when SemVer condition matches', () {
      final override = TargetingOverride(
        configKeyId: UuidValue.newUuid(),
        priority: 1,
        appVersionConstraint: '>= 2.0.0',
        servedValue: 'true',
        isActive: true,
      );
      final repo = RemoteConfigRepository();
      final matches = repo.matchesOverride(override, appVersion: '2.1.0', platform: 'android');
      expect(matches, isTrue);
    });

    test('evaluateOverride returns false when SemVer condition fails', () {
      final override = TargetingOverride(
        configKeyId: UuidValue.newUuid(),
        priority: 1,
        appVersionConstraint: '>= 2.0.0',
        servedValue: 'true',
        isActive: true,
      );
      final repo = RemoteConfigRepository();
      final matches = repo.matchesOverride(override, appVersion: '1.5.0', platform: 'android');
      expect(matches, isFalse);
    });

    test('deterministic canary hashing returns consistent result for same userId', () {
      final repo = RemoteConfigRepository();
      final score1 = repo.calculateCanaryScore('user_123', 'enable_feature');
      final score2 = repo.calculateCanaryScore('user_123', 'enable_feature');
      expect(score1, equals(score2));
      expect(score1, isA<int>());
      expect(score1 >= 1 && score1 <= 100, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm dart test test/unit/features/remote_config/remote_config_repository_test.dart` inside `baktaz_server/`
Expected: FAIL with compilation error (missing `RemoteConfigRepository`).

- [ ] **Step 3: Write interface and implementation**

Create `baktaz_server/lib/src/features/remote_config/domain/interface/i_remote_config_repository.dart`:
```dart
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

abstract interface class IRemoteConfigRepository {
  Future<RemoteConfig> evaluateConfig(
    Session session, {
    required String appVersion,
    required String platform,
    String? userId,
    String? userTier,
    String? customSegment,
  });

  void invalidateCache(Session session);
}
```

Create `baktaz_server/lib/src/features/remote_config/data/repository/remote_config_repository.dart`:
```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod/serverpod.dart';
import 'package:baktaz_server/src/features/remote_config/domain/interface/i_remote_config_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';

@LazySingleton(as: IRemoteConfigRepository)
class RemoteConfigRepository implements IRemoteConfigRepository {
  static const String _cacheKey = 'rc:template';

  @override
  Future<RemoteConfig> evaluateConfig(
    Session session, {
    required String appVersion,
    required String platform,
    String? userId,
    String? userTier,
    String? customSegment,
  }) async {
    final (keys, overrides, version) = await _getCompiledData(session);

    final Map<String, RemoteConfigValue> evaluatedMap = {};

    for (final configKey in keys) {
      final keyOverrides = overrides.where((o) => o.configKeyId == configKey.id).toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));

      String selectedValue = configKey.defaultValue;

      for (final override in keyOverrides) {
        if (matchesOverride(
          override,
          appVersion: appVersion,
          platform: platform,
          userId: userId,
          userTier: userTier,
          customSegment: customSegment,
          keyName: configKey.key,
        )) {
          selectedValue = override.servedValue;
          break;
        }
      }

      evaluatedMap[configKey.key] = RemoteConfigValue(
        defaultValue: RemoteConfigDefaultValue(value: configKey.defaultValue),
        valueType: configKey.valueType,
        value: selectedValue,
      );
    }

    final publicVersion = PublicConfigVersion(
      versionNumber: version?.versionNumber ?? '1.0.0',
      updateTime: version?.updateTime ?? DateTime.now(),
    );

    return RemoteConfig(
      config: evaluatedMap,
      version: publicVersion,
    );
  }

  bool matchesOverride(
    TargetingOverride override, {
    required String appVersion,
    required String platform,
    String? userId,
    String? userTier,
    String? customSegment,
    String? keyName,
  }) {
    if (override.appVersionConstraint != null && override.appVersionConstraint!.isNotEmpty) {
      try {
        final constraint = VersionConstraint.parse(override.appVersionConstraint!);
        final clientVer = Version.parse(appVersion);
        if (!constraint.allows(clientVer)) return false;
      } catch (_) {
        return false;
      }
    }

    if (override.userTiers != null && override.userTiers!.isNotEmpty) {
      if (userTier == null || !override.userTiers!.contains(userTier)) return false;
    }

    if (override.customSegmentValues != null && override.customSegmentValues!.isNotEmpty) {
      if (customSegment == null || !override.customSegmentValues!.contains(customSegment)) return false;
    }

    if (override.rolloutPercentage != null && userId != null && keyName != null) {
      final score = calculateCanaryScore(userId, keyName);
      if (score > override.rolloutPercentage!) return false;
    }

    return true;
  }

  int calculateCanaryScore(String userId, String keyName) {
    final bytes = utf8.encode('$userId:$keyName');
    final hash = sha256.convert(bytes);
    final BigInt numeric = BigInt.parse(hash.toString().substring(0, 8), radix: 16);
    return (numeric % BigInt.from(100)).toInt() + 1;
  }

  Future<(List<ConfigKey>, List<TargetingOverride>, ConfigSnapshotVersion?)> _getCompiledData(
    Session session,
  ) async {
    final keys = await ConfigKey.db.find(session);
    final overrides = await TargetingOverride.db.find(
      session,
      where: (t) => t.isActive.equals(true),
    );
    final version = await ConfigSnapshotVersion.db.findFirstRow(
      session,
      orderBy: (t) => t.updateTime,
      orderDescending: true,
    );
    return (keys, overrides, version);
  }

  @override
  void invalidateCache(Session session) {
    session.caches.local.invalidateKey(_cacheKey);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm dart test test/unit/features/remote_config/remote_config_repository_test.dart` inside `baktaz_server/`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add baktaz_server/lib/src/features/remote_config/ baktaz_server/test/unit/features/remote_config/
git commit -m "feat(remote_config): add RemoteConfigRepository with evaluation engine and active overrides query"
```

---

### Task 4: Implement RemoteConfig Endpoint & Seeder (`baktaz_server`)

**Files:**
- Create: `baktaz_server/lib/src/features/remote_config/endpoint/remote_config_endpoint.dart`
- Modify: `baktaz_server/lib/src/app/utils/seeding_utils.dart`
- Modify: `baktaz_server/lib/server.dart`
- Create: `baktaz_server/test/integration/features/remote_config/remote_config_endpoint_test.dart`

**Interfaces:**
- Consumes: `IRemoteConfigRepository`.
- Produces: `RemoteConfigEndpoint.getRemoteConfig(Session session, ...)` public unauthenticated Serverpod endpoint.

- [ ] **Step 1: Write integration test**

Create `baktaz_server/test/integration/features/remote_config/remote_config_endpoint_test.dart`:
```dart
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import '../../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('RemoteConfigEndpoint Integration Tests', (sessionBuilder, endpoints) {
    test('getRemoteConfig returns valid default values when seeded', () async {
      final session = sessionBuilder.build();
      final config = await endpoints.remoteConfig.getRemoteConfig(
        session,
        appVersion: '1.0.0',
        platform: 'android',
      );
      expect(config, isNotNull);
      expect(config.config.containsKey('is_maintenance'), isTrue);
      expect(config.config['is_maintenance']?.value, equals('false'));
    });
  });
}
```

- [ ] **Step 2: Implement endpoint and seeder**

Create `baktaz_server/lib/src/features/remote_config/endpoint/remote_config_endpoint.dart`:
```dart
import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/remote_config/domain/interface/i_remote_config_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

final class RemoteConfigEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  final IRemoteConfigRepository _repository = getIt<IRemoteConfigRepository>();

  Future<RemoteConfig> getRemoteConfig(
    Session session, {
    required String appVersion,
    required String platform,
    String? userId,
    String? userTier,
    String? customSegment,
  }) async {
    return _repository.evaluateConfig(
      session,
      appVersion: appVersion,
      platform: platform,
      userId: userId,
      userTier: userTier,
      customSegment: customSegment,
    );
  }
}
```

Add `seedRemoteConfig(Session session)` in `baktaz_server/lib/src/app/utils/seeding_utils.dart`:
```dart
Future<void> seedRemoteConfig(Session session) async {
  try {
    final defaultKeys = [
      ('is_maintenance', RemoteConfigValueType.boolean, 'false', 'Enable maintenance mode'),
      ('min_supported_version', RemoteConfigValueType.string, '1.0.0', 'Minimum supported app version'),
      ('android_store_url', RemoteConfigValueType.string, 'https://play.google.com/store/apps/details?id=com.baktaz.app', 'Android Store URL'),
      ('ios_store_url', RemoteConfigValueType.string, 'https://apps.apple.com/app/baktaz/id123456789', 'iOS Store URL'),
      ('help_center_url', RemoteConfigValueType.string, 'https://help.baktaz.com', 'Help center URL'),
      ('about_us_url', RemoteConfigValueType.string, 'https://baktaz.com/about', 'About us URL'),
      ('privacy_policy_url', RemoteConfigValueType.string, 'https://baktaz.com/privacy', 'Privacy policy URL'),
      ('enable_chat', RemoteConfigValueType.boolean, 'true', 'Enable chat feature'),
      ('enable_payout', RemoteConfigValueType.boolean, 'true', 'Enable payout feature'),
      ('enable_challenges', RemoteConfigValueType.boolean, 'true', 'Enable challenge feature'),
    ];

    for (final (key, type, defVal, desc) in defaultKeys) {
      final existing = await ConfigKey.db.findFirstRow(session, where: (t) => t.key.equals(key));
      if (existing == null) {
        await ConfigKey.db.insertRow(
          session,
          ConfigKey(
            key: key,
            valueType: type,
            defaultValue: defVal,
            description: desc,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    final versionCount = await ConfigSnapshotVersion.db.count(session);
    if (versionCount == 0) {
      await ConfigSnapshotVersion.db.insertRow(
        session,
        ConfigSnapshotVersion(
          versionNumber: '1.0.0',
          updateTime: DateTime.now(),
          updateOrigin: 'seeder',
          updateType: 'initial',
        ),
      );
    }

    session.log('Successfully seeded remote config defaults.');
  } catch (e, stack) {
    session.log('Failed to seed remote config: $e', level: LogLevel.error, stackTrace: stack);
  }
}
```

Call `await seedRemoteConfig(session);` in `baktaz_server/lib/server.dart`.

- [ ] **Step 3: Run Serverpod codegen and dependencies build**

Run `rtk dart run serverpod_cli generate` in `baktaz_server/`

- [ ] **Step 4: Run integration test**

Run: `fvm dart test test/integration/features/remote_config/remote_config_endpoint_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add baktaz_server/lib/src/features/remote_config/endpoint/ baktaz_server/lib/src/app/utils/seeding_utils.dart baktaz_server/lib/server.dart baktaz_server/test/integration/features/remote_config/
git commit -m "feat(remote_config): add public unauthenticated RemoteConfigEndpoint and seeder"
```

---

### Task 5: Implement `ServerpodRemoteConfigService` in `baktaz_flutter`

**Files:**
- Create: `baktaz_flutter/lib/core/data/service/serverpod_remote_config_service.dart`
- Modify: `baktaz_flutter/lib/app/helpers/injection/service_module.dart`
- Create: `baktaz_flutter/test/unit/serverpod_remote_config_service_test.dart`

**Interfaces:**
- Consumes: `baktaz_client` (`client.remoteConfig.getRemoteConfig`), `IRemoteConfigService`, `IDeviceInfoRepository`.
- Produces: `ServerpodRemoteConfigService` registered as `IRemoteConfigService`.

- [ ] **Step 1: Write unit test**

Create `baktaz_flutter/test/unit/serverpod_remote_config_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:baktaz_flutter/core/data/service/serverpod_remote_config_service.dart';
import 'package:baktaz_flutter/core/domain/interface/i_device_info_repository.dart';
import 'package:mockito/mockito.dart';
import '../utils/generated_mocks.dart';

void main() {
  test('ServerpodRemoteConfigService fallback map contains default values', () async {
    final mockDeviceInfo = MockIDeviceInfoRepository();
    final service = ServerpodRemoteConfigService(mockDeviceInfo);
    final config = await service.remoteConfig;
    expect(config.containsKey('is_maintenance'), isTrue);
    expect(config['is_maintenance'], equals(false));
  });
}
```

- [ ] **Step 2: Implement `ServerpodRemoteConfigService`**

Create `baktaz_flutter/lib/core/data/service/serverpod_remote_config_service.dart`:
```dart
import 'dart:async';
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/core/data/dto/remote_app_config.dto.dart';
import 'package:baktaz_flutter/core/domain/interface/i_device_info_repository.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:injectable/injectable.dart';
import 'package:mobile_service_core/features/remote_config/i_remote_config_service.dart';

@LazySingleton(as: IRemoteConfigService)
class ServerpodRemoteConfigService implements IRemoteConfigService {
  final IDeviceInfoRepository _deviceInfoRepository;

  ServerpodRemoteConfigService(this._deviceInfoRepository);

  final StreamController<dynamic> _controller = StreamController<dynamic>.broadcast();
  Map<String, dynamic> _cachedConfig = RemoteAppConfigDTO.fallback().toJson();

  @override
  Future<StreamSubscription<dynamic>> initializeConfig(void Function(dynamic)? onData) async {
    if (onData != null) {
      return _controller.stream.listen(onData);
    }
    return _controller.stream.listen((_) {});
  }

  @override
  Future<Map<String, dynamic>> get remoteConfig async {
    try {
      final client = getIt<Client>();
      final appVersionResult = _deviceInfoRepository.getAppVersion();
      final appVersion = appVersionResult.fold(
        (_) => '1.0.0',
        (version) => version,
      );
      final platform = kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase();

      final result = await client.remoteConfig.getRemoteConfig(
        appVersion: appVersion,
        platform: platform,
      );

      final Map<String, dynamic> map = {};
      result.config.forEach((key, val) {
        switch (val.valueType) {
          case RemoteConfigValueType.boolean:
            map[key] = val.value.toLowerCase() == 'true';
          case RemoteConfigValueType.integer:
            map[key] = int.tryParse(val.value) ?? 0;
          case RemoteConfigValueType.double:
            map[key] = double.tryParse(val.value) ?? 0.0;
          case RemoteConfigValueType.string:
          case RemoteConfigValueType.json:
            map[key] = val.value;
        }
      });

      _cachedConfig = map;
      _controller.add(_cachedConfig);
      return map;
    } catch (_) {
      return _cachedConfig;
    }
  }

  @override
  Future<String?> getString(String key) async {
    final map = await remoteConfig;
    return map[key]?.toString();
  }
}
```

- [ ] **Step 3: Run flutter tests**

Run: `fvm flutter test test/unit/serverpod_remote_config_service_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add baktaz_flutter/lib/core/data/service/serverpod_remote_config_service.dart baktaz_flutter/test/unit/serverpod_remote_config_service_test.dart
git commit -m "feat(remote_config): add ServerpodRemoteConfigService with IDeviceInfoRepository injection in Flutter"
```

---

### Task 6: Update `RemoteConfigCubit` and `RemoteConfigState` (`baktaz_flutter`)

**Files:**
- Modify: `baktaz_flutter/lib/core/domain/cubit/remote_config/remote_config_state.dart`
- Modify: `baktaz_flutter/lib/core/domain/cubit/remote_config/remote_config_cubit.dart`
- Modify: `baktaz_flutter/test/unit/remote_config_cubit_test.dart`

**Interfaces:**
- Consumes: `RemoteConfigState`, `RemoteConfigCubit`.
- Produces: `isChatEnabled`, `isPayoutEnabled`, `isChallengesEnabled` getters on `RemoteConfigState` and `RemoteConfigCubit`.

- [ ] **Step 1: Write failing unit test for feature flags**

Modify `baktaz_flutter/test/unit/remote_config_cubit_test.dart`:
```dart
test('RemoteConfigState exposes feature flag getters correctly', () {
  const state = RemoteConfigState(values: {
    'enable_chat': true,
    'enable_payout': 'true',
    'enable_challenges': false,
  });

  expect(state.isChatEnabled, isTrue);
  expect(state.isPayoutEnabled, isTrue);
  expect(state.isChallengesEnabled, isFalse);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/unit/remote_config_cubit_test.dart`
Expected: FAIL with compilation error (getters `isChatEnabled`, `isPayoutEnabled`, `isChallengesEnabled` not defined).

- [ ] **Step 3: Implement getters in `RemoteConfigState` and `RemoteConfigCubit`**

Modify `baktaz_flutter/lib/core/domain/cubit/remote_config/remote_config_state.dart`:
```dart
part of 'remote_config_cubit.dart';

@freezed
sealed class RemoteConfigState with _$RemoteConfigState {
  const factory RemoteConfigState({@Default(<String, dynamic>{}) Map<String, dynamic> values}) = _RemoteConfigState;

  const RemoteConfigState._();

  bool get isMaintenance => values['is_maintenance'] == true || values['is_maintenance'] == 'true';

  String? get minSupportedVersion => values['min_supported_version'] as String?;

  String? get androidStoreUrl => values['android_store_url'] as String?;

  String? get iosStoreUrl => values['ios_store_url'] as String?;

  bool get isChatEnabled => values['enable_chat'] == true || values['enable_chat'] == 'true';

  bool get isPayoutEnabled => values['enable_payout'] == true || values['enable_payout'] == 'true';

  bool get isChallengesEnabled => values['enable_challenges'] == true || values['enable_challenges'] == 'true';

  /// Escape hatch for dynamic admin-defined keys (e.g. webview configKey).
  String? value(String key) => values[key] as String?;
}
```

Modify `baktaz_flutter/lib/core/domain/cubit/remote_config/remote_config_cubit.dart`:
```dart
bool get isChatEnabled => stateValue.isChatEnabled;
bool get isPayoutEnabled => stateValue.isPayoutEnabled;
bool get isChallengesEnabled => stateValue.isChallengesEnabled;
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/unit/remote_config_cubit_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add baktaz_flutter/lib/core/domain/cubit/remote_config/ baktaz_flutter/test/unit/remote_config_cubit_test.dart
git commit -m "feat(remote_config): add feature flag getters to RemoteConfigState and RemoteConfigCubit"
```
