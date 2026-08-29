# Account Feature Comprehensive Testing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Write comprehensive unit tests, widget tests, golden tests, and serverpod endpoint integration tests covering all Account feature logic, UI, and backend API flows.

**Architecture:** Use `mockito` for mocked client and repository generation. Test Cubit state transitions with `bloc_test` and pure Dart `test`. Implement UI visual golden tests with `alchemist` under `test/widget/account/`. Conduct serverpod integration tests using `withServerpod` under `test/integration/account/`.

**Tech Stack:** `flutter_test`, `test`, `mockito`, `alchemist` (15% tolerance), `serverpod_test`.

**Spec:** `docs/specs/account_feature_spec.md`

## Global Constraints

- Tests written ONLY AFTER all implementation tasks (00-03) are completed.
- Target 100% coverage for Cubits and Repositories.
- Target 80% coverage for UI screens and widgets.
- AAA Pattern (Arrange-Act-Assert) strictly followed.
- Generated mock file resides in `test/utils/generated_mocks.dart`.

---

### Task 1: Test Setup & Mock Generation

**Files:**
- Create: `baktaz_flutter/test/utils/generated_mocks.dart`
- Create: `baktaz_server/test/utils/generated_mocks.dart`

**Interfaces:**
- Consumes: `mockito` annotations.
- Produces: Auto-generated mocks for `IAccountRepository`, `IHostSubscriptionRepository`, `IPayoutRepository`, `Client`.

- [ ] **Step 1: Write Mock Annotations**

Create `baktaz_flutter/test/utils/generated_mocks.dart`:
```dart
import 'package:mockito/annotations.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_host_subscription_repository.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_payout_repository.dart';

@GenerateMocks([
  IAccountRepository,
  IHostSubscriptionRepository,
  IPayoutRepository,
])
void main() {}
```

- [ ] **Step 2: Run build_runner to generate mocks**

Run: `cd baktaz_flutter && fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `generated_mocks.mocks.dart` created in `test/utils/`.

- [ ] **Step 3: Commit mocks**

```bash
git add baktaz_flutter/test/utils/
git commit -m "test(flutter): setup account feature mock generation"
```

---

### Task 2: Cubit Unit Tests

**Files:**
- Create: `baktaz_flutter/test/unit/account/account_cubit_test.dart`
- Create: `baktaz_flutter/test/unit/account/host_subscription_cubit_test.dart`
- Create: `baktaz_flutter/test/unit/account/payment_cubit_test.dart`
- Create: `baktaz_flutter/test/unit/account/health_sync_cubit_test.dart`

**Interfaces:**
- Consumes: `mockito` mocks, `bloc_test`.
- Produces: 100% cubit logic coverage.

- [ ] **Step 1: Write AccountCubit Test**

Create `baktaz_flutter/test/unit/account/account_cubit_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:baktaz_flutter/features/account/presentation/cubit/account_cubit.dart';
import 'package:baktaz_flutter/features/account/presentation/cubit/account_state.dart';
import '../../utils/generated_mocks.mocks.dart';

void main() {
  late AccountCubit cubit;
  late MockIAccountRepository mockRepo;

  setUp(() {
    mockRepo = MockIAccountRepository();
    cubit = AccountCubit(mockRepo);
  });

  group('AccountCubit', () {
    test('initialState is Initial', () {
      expect(cubit.state, isA<AccountState>());
    });
  });
}
```

- [ ] **Step 2: Run Cubit tests**

Run: `cd baktaz_flutter && fvm flutter test test/unit/account/account_cubit_test.dart`
Expected: PASS.

- [ ] **Step 3: Commit Cubit Tests**

```bash
git add baktaz_flutter/test/unit/account/
git commit -m "test(flutter): add AccountCubit unit tests"
```

---

### Task 3: Widget & Golden Tests

**Files:**
- Create: `baktaz_flutter/test/widget/account/account_header_card_test.dart`
- Create: `baktaz_flutter/test/widget/account/goldens/account_header_card_macos.png`
- Create: `baktaz_flutter/test/widget/account/account_menu_tile_test.dart`
- Create: `baktaz_flutter/test/widget/account/goldens/account_menu_tile_macos.png`

**Interfaces:**
- Consumes: `alchemist`, `flutter_test`.
- Produces: UI golden image baselines for regression.

- [ ] **Step 1: Write AccountHeaderCard Golden Test**

Create `baktaz_flutter/test/widget/account/account_header_card_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alchemist/alchemist.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_header_card.dart';
import 'package:baktaz_client/baktaz_client.dart';

void main() {
  final userInfo = UserInfo(
    userId: UuidValue.fromString('11111111-1111-1111-1111-111111111111'),
    fullName: 'Test User',
    email: 'test@example.com',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  goldenTest(
    'renders correctly',
    fileName: 'account_header_card_macos',
    builder: () => GoldenTestGroup(
      scenarioConstraints: const BoxConstraints(maxWidth: 400),
      children: [
        GoldenTestScenario(
          name: 'with avatar',
          child: Material(
            child: AccountHeaderCard(
              userInfo: userInfo,
              onEditProfile: () {},
            ),
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: Run Golden Tests to generate baselines**

Run: `cd baktaz_flutter && fvm flutter test test/widget/account/account_header_card_test.dart --update-goldens`
Expected: Baseline golden image created.

- [ ] **Step 3: Commit Goldens**

```bash
git add baktaz_flutter/test/widget/account/
git commit -m "test(flutter): add AccountHeaderCard widget and golden tests"
```

---

### Task 4: Serverpod Endpoint Integration Tests

**Files:**
- Create: `baktaz_server/test/integration/account/account_endpoint_test.dart`
- Create: `baktaz_server/test/integration/account/host_subscription_endpoint_test.dart`

**Interfaces:**
- Consumes: `serverpod_test`, `withServerpod`, generated mocks.
- Produces: Server endpoint contract verification.

- [ ] **Step 1: Write Serverpod Integration Test Setup**

Create `baktaz_server/test/integration/account/account_endpoint_test.dart`:
```dart
import 'package:test/test.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:serverpod/serverpod.dart';

void main() {
  withServerpod('Given AccountEndpoint', (endpoints, session) {
    test('when calling getSummary without login then throws unauthorized', () async {
      expect(
        () => endpoints.account.getSummary(session),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
```

- [ ] **Step 2: Run Integration Tests (requires local Postgres)**

Run: `cd baktaz_server && fvm dart test test/integration/account/account_endpoint_test.dart`
Expected: PASS.

- [ ] **Step 3: Commit Serverpod Tests**

```bash
git add baktaz_server/test/integration/account/
git commit -m "test(server): add AccountEndpoint and HostSubscriptionEndpoint integration tests"
```

---

### Task 5: Final Code Coverage Verification

**Files:** None.

**Interfaces:** None.

- [ ] **Step 1: Generate coverage reports**

Run: `cd baktaz_flutter && fvm flutter test --coverage`
Run: `cd baktaz_server && fvm dart test --coverage`

- [ ] **Step 2: Verify coverage percentages**

Target: ≥80% UI, 100% Cubits/Repos.

- [ ] **Step 3: Final commit with coverage badge if required**

```bash
git commit --allow-empty -m "test: final Account feature coverage validation"
```
