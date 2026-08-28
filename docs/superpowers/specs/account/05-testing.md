# Account Feature Architecture Spec — Testing & Verification Strategy

> **Document Version:** 1.0  
> **Date:** 2026-08-28  
> **Parent Spec:** `docs/superpowers/specs/account/00-overview.md`  
> **Packages:** `baktaz_flutter`, `baktaz_server`  

---

## 1. Overview

Testing strictly follows the **Implementation-First Workflow**: all code, codegen (`slang`, `build_runner`, `serverpod generate`), database migrations, and cross-package compilation must be complete and verified prior to initiating any test creation. 

The testing architecture relies on **100% Unit Coverage** for business logic, **80% coverage** for UI components, and strictly isolated server integration tests.

---

## 2. Unit Testing Strategy (100% Target)

### 2.1 Scope

All Cubit state classes and Repository contracts must achieve **100% branch and method coverage**. Unit tests reside in `test/unit/`.

### 2.2 `AccountCubit` Test Structure

Uses `bloc_test` package with `blocTest` to test synchronous and asynchronous state emissions in conjunction with `TaskResult`.

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baktaz_flutter/features/account/presentation/cubit/account_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:mockito/mockito.dart';

import '../../utils/generated_mocks.dart';

void main() {
  late AccountCubit cubit;
  late MockIAccountRepository mockRepo;
  late MockFailureHandler mockHandler;

  setUp(() {
    mockRepo = MockIAccountRepository();
    mockHandler = MockFailureHandler();
    cubit = AccountCubit(mockRepo, mockHandler);
  });

  tearDown(() => cubit.close());

  group('fetchSummary', () {
    final mockSummary = AccountSummary(
      userInfo: UserInfo(
        id: const UuidValue.v4(),
        fullName: 'Juan Dela Cruz',
        username: 'juandelacruz',
        memberSince: DateTime(2026, 8, 1),
      ),
      isPremiumHost: false,
      challengeStepsTotal: 120000,
      challengesJoined: 15,
      challengesWon: 2,
    );

    blocTest<AccountCubit, AccountState>(
      'emits [loading, loaded] when fetchSummary succeeds',
      build: () {
        when(mockRepo.getAccountSummary())
            .thenAnswer((_) async => right(mockSummary));
        return AccountCubit(mockRepo, mockHandler);
      },
      act: (cubit) => cubit.fetchSummary(),
      expect: () => [
        const AccountState.loading(),
        AccountState.loaded(summary: mockSummary),
      ],
      verify: (_) {
        verify(mockRepo.getAccountSummary()).called(1);
      },
    );

    blocTest<AccountCubit, AccountState>(
      'emits [loading, failed] and triggers FailureHandler when fetchSummary fails',
      build: () {
        when(mockRepo.getAccountSummary())
            .thenAnswer((_) async => left(const ServerFailure(500)));
        return AccountCubit(mockRepo, mockHandler);
      },
      act: (cubit) => cubit.fetchSummary(),
      expect: () => [
        const AccountState.loading(),
        const AccountState.failed(),
      ],
      verify: (_) {
        verify(mockHandler.handleFailure(any)).called(1);
      },
    );
  });
}
```

### 2.3 `HostSubscriptionCubit` Test Structure

```dart
  group('validateVoucher', () {
    blocTest<HostSubscriptionCubit, HostSubscriptionState>(
      'emits [isValidatingVoucher = true, isValidatingVoucher = false, appliedVoucher set]',
      build: () {
        when(mockRepo.getPackages()).thenAnswer((_) async => right([testPackage]));
        return HostSubscriptionCubit(mockRepo, mockHandler);
      },
      seed: () => HostSubscriptionState.loaded(
        packages: [testPackage],
        selectedPackage: testPackage,
      ),
      act: (cubit) async {
        await cubit.loadPackages();
        when(mockRepo.validateVoucher('LAUNCH50'))
            .thenAnswer((_) async => right(mockVoucher));
        return cubit.validateVoucher('LAUNCH50');
      },
      expect: () => [
        const HostSubscriptionState.loading(),
        HostSubscriptionState.loaded(packages: [testPackage], selectedPackage: testPackage),
        HostSubscriptionState.loaded(
          packages: [testPackage],
          selectedPackage: testPackage,
          isValidatingVoucher: true,
        ),
        HostSubscriptionState.loaded(
          packages: [testPackage],
          selectedPackage: testPackage,
          isValidatingVoucher: false,
          appliedVoucher: mockVoucher,
        ),
      ],
    );
  });
```

### 2.4 Mocking Setup (`test/utils/generated_mocks.dart`)

Use `@GenerateMocks` for strict typing. Generate once, import globally.

```dart
import 'package:baktaz_flutter/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_host_subscription_repository.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_payout_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

@GenerateMocks([
  IAccountRepository,
  IHostSubscriptionRepository,
  IPayoutRepository,
  FailureHandler,
])
void main() {}
```

---

## 3. Widget & Golden Testing Strategy (80% Target)

### 3.1 Scope

All complex UI screens and reusable account widgets must render correctly under standard and Dark Mode configurations. Test files reside in `test/widget/account/`.

### 3.2 Test Rules

- Run on `macos` (local development) and `ci` (headless Linux simulator).
- Generate and verify golden master images with a 15% tolerance (`AlchemistConfig`).
- Assert widget hierarchy renders core semantic labels and visual structure (`findsOneWidget`).
- Do **NOT** test screens via full routed navigation; test isolated widgets/sections.

### 3.3 `AccountPage` Golden Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:baktaz_flutter/features/account/presentation/views/account_page.dart';

void main() {
  group('AccountPage', () {
    goldenTest(
      'renders correctly in light mode',
      fileName: 'account_page_light',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints.tightFor(width: 390, height: 844),
        children: [
          GoldenTestScenario(
            name: 'initial loading',
            child: const MaterialApp(
              home: Scaffold(body: AccountPage(isMockLoading: true)),
            ),
          ),
          GoldenTestScenario(
            name: 'loaded state',
            child: MaterialApp(
              home: Scaffold(
                body: AccountPage(
                  isMockLoading: false,
                  mockSummary: mockAccountSummary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
```

### 3.4 `ManagePaymentScreen` Widget Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baktaz_flutter/features/account/presentation/views/manage_payment_screen.dart';
import 'package:baktaz_flutter/features/account/presentation/cubit/payment_cubit.dart';
import '../../utils/generated_mocks.dart';

void main() {
  testWidgets('displays empty state when no payout destination exists', (tester) async {
    final mockCubit = MockPaymentCubit();
    when(mockCubit.state).thenReturn(const PaymentState.loaded(
      savedMethods: [],
      payoutDestination: null,
    ));
    when(() => mockCubit.close()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PaymentCubit>.value(
          value: mockCubit,
          child: const ManagePaymentScreen(),
        ),
      ),
    );

    expect(find.text('No payout destination set'), findsOneWidget);
    expect(find.text('Add Payment Method'), findsOneWidget);
  });
}
```

---

## 4. Serverpod Integration Testing Strategy

### 4.1 Scope

Strictly backend Serverpod endpoints interacting with real databases. Resides in `baktaz_server/test/integration/features/account/`. These tests execute inside Docker containers (`withServerpod`) and are excluded from standard CI pipelines.

### 4.2 Execution Command

```bash
cd baktaz_server
fvm dart test test/integration/features/account/ --concurrency=1
```

### 4.3 Host Cut Forfeiture Logic Test

Validates the crucial edge case where host cuts are lost due to expired subscriptions.

```dart
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';
import 'package:baktaz_client/baktaz_client.dart';

void main() async {
  withServerpod('Host Cut Forfeiture Tests', (run, session) {
    test('forfeits host cut when subscription expires before challenge settlement', () async {
      final userId = session.authenticated!.userId;
      
      // 1. Create user and active host subscription expiring tomorrow
      await HostSubscription.db.insertRow(session, HostSubscription(
        userId: userId,
        packageId: const UuidValue.v4(),
        status: 'active',
        startedAt: DateTime.now().subtract(const Duration(days: 30)),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        autoRenew: false,
      ));

      // 2. Create a challenge that just ended (expiresAt in the past)
      final challenge = await Challenge.db.insertRow(session, Challenge(
        hostId: userId,
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        // ... other required fields
      ));

      // 3. Run settlement process
      await ChallengeRepository(session).settleChallenge(challenge.id!);

      // 4. Verify host cut payout is set to 0 and reason is logged
      final payout = await Payout.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(userId) & t.challengeId.equals(challenge.id!),
      );

      expect(payout, isNotNull);
      expect(payout!.netHostCut, equals(0));
      expect(payout.failureReason, equals('SUBSCRIPTION_EXPIRED_AT_COMPLETION'));
    });
  });
}
```

---

## 5. Coverage Configuration

### Exclusions (`.coverage_exclude`)

```text
**/*.g.dart
**/*.freezed.dart
**/*.config.dart
**/*.mocks.dart
lib/app/generated/
lib/src/generated/
test/integration/
```

### CI Verification Target

```bash
# Flutter Coverage
cd baktaz_flutter
flutter test --coverage
lcov --list coverage/lcov.info

# Verify minimums
test -f coverage/lcov.info
```

---
