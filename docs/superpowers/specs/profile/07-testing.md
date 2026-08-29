# Profile Header & Lifetime Stats — Testing Strategy

> **Document Version:** 1.0  
> **Date:** 2026-08-29  
> **Parent Spec:** `docs/superpowers/specs/account/profile/00-overview.md`

---

## Testing Principles

- **Implementation First**: All code, codegen, migrations, and cross-package compilation must be complete and verified before any test creation
- **100% Unit Coverage**: Cubits, repositories, and utils
- **80% Widget/Golden Coverage**: UI components
- **Integration Tests**: Serverpod endpoints with real database (`withServerpod`)
- **TDD**: Write failing test → verify fail → implement → verify pass

---

## 1. Server Integration Tests

**Location:** `baktaz_server/test/integration/features/account/account_endpoint_test.dart`

```dart
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';
import 'package:baktaz_client/baktaz_client.dart';

void main() {
  withServerpod('AccountEndpoint Tests', (run, session) {
    final AccountEndpoint endpoint = AccountEndpoint();

    group('getAccountSummary', () {
      test('returns memberSince from Account.createdAt', () async {
        final Account account = await Account.db.insertRow(session, Account(
          authUserId: session.authenticated!.userId,
          createdAt: DateTime(2024, 1, 15),
        ));
        final AccountSummary? summary = await endpoint.getAccountSummary(session);
        expect(summary?.memberSince, equals(DateTime(2024, 1, 15)));
      });

      test('returns challenge stats from repository', () async {
        final AccountSummary? summary = await endpoint.getAccountSummary(session);
        expect(summary?.totalChallengeSteps, equals(0));
        expect(summary?.winRatePercentage, equals(0.0));
      });
    });

    group('updateProfile', () {
      test('updates firstName and lastName', () async {
        final UserInfo userInfo = await UserInfo.db.insertRow(session, UserInfo(
          firstName: 'Old',
          lastName: 'Name',
          username: 'oldname',
          gender: Gender.unknown,
        ));
        final Profile updated = await endpoint.updateProfile(session, UpdateProfileRequest(
          firstName: 'New',
          lastName: 'Name',
        ));
        expect(updated.firstName, equals('New'));
        expect(updated.lastName, equals('Name'));
      });

      test('throws notFound when userInfo does not exist', () async {
        expect(
          () => endpoint.updateProfile(session, UpdateProfileRequest(firstName: 'Test', lastName: 'User')),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', equals(ApiExceptionCode.notFound))),
        );
      });

      test('updates avatarUrl', () async {
        final Profile updated = await endpoint.updateProfile(session, UpdateProfileRequest(
          firstName: 'Test',
          lastName: 'User',
          avatarUrl: 'https://example.com/avatar.webp',
        ));
        expect(updated.imageUrl, isNotNull);
      });
    });

    group('getAvatarUploadUrl', () {
      test('returns valid presigned URL with correct file key', () async {
        final AvatarUploadUrl result = await endpoint.getAvatarUploadUrl(session);
        expect(result.uploadUrl, isNotEmpty);
        expect(result.fileKey, startsWith('avatars/'));
        expect(result.expiresAt, isAfter(DateTime.now()));
      });
    });
  });
}
```

---

## 2. Auth Repository Tests

**Location:** `baktaz_server/test/unit/features/auth/auth_repository_test.dart`

```dart
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:baktaz_server/src/features/auth/data/repository/auth_repository.dart';

@GenerateMocks([SecurityLogger])
void main() {
  withServerpod('AuthRepository Tests', (run, session) {
    late AuthRepository authRepository;

    setUp(() {
      authRepository = AuthRepository(MockSecurityLogger());
    });

    group('completeRegistration', () {
      test('derives username from email with collision handling', () async {
        when(mockSecurityLogger.log(any, any, any: anyNamed(''), any: anyNamed(''))).thenAnswer((_) async {});

        await authRepository.completeRegistration(session, RegistrationForm(
          email: 'juan@example.com',
          firstName: 'Juan',
          lastName: 'Dela Cruz',
          gender: 'male',
          registrationToken: 'valid-token',
        ));

        final UserInfo? userInfo = await UserInfo.db.findFirstRow(
          session,
          where: (UserInfoTable t) => t.firstName.equals('Juan'),
        );
        expect(userInfo?.username, equals('juan'));
      });

      test('appends collision suffix when username exists', () async {
        await UserInfo.db.insertRow(session, UserInfo(
          firstName: 'Existing',
          lastName: 'User',
          username: 'juan',
          gender: Gender.unknown,
        ));

        await authRepository.completeRegistration(session, RegistrationForm(
          email: 'juan2@example.com',
          firstName: 'Juan',
          lastName: 'Two',
          gender: 'male',
          registrationToken: 'valid-token',
        ));

        final UserInfo? newUserInfo = await UserInfo.db.findFirstRow(
          session,
          where: (UserInfoTable t) => t.lastName.equals('Two'),
        );
        expect(newUserInfo?.username, startsWith('juan'));
        expect(newUserInfo?.username.length, greaterThan(4)); // has suffix
      });
    });
  });
}
```

---

## 3. UsernameUtils Unit Tests

**Location:** `baktaz_server/test/unit/utils/username_utils_test.dart`

```dart
import 'package:test/test.dart';
import 'package:baktaz_server/src/app/utils/username_utils.dart';

void main() {
  group('UsernameUtils', () {
    test('deriveFromEmail cleans local-part and lowercases', () {
      expect(UsernameUtils.deriveFromEmail('Juan.DelaCruz+test@Example.com'), equals('juan.delacruz'));
      expect(UsernameUtils.deriveFromEmail('user_name123@domain.org'), equals('user_name123'));
      expect(UsernameUtils.deriveFromEmail('USER123@app.co.uk'), equals('user123'));
    });

    test('deriveFromEmail returns empty for invalid email', () {
      expect(UsernameUtils.deriveFromEmail(''), equals(''));
    });
  });
}
```

---

## 4. Flutter Unit Tests

**Location:** `baktaz_flutter/test/unit/profile_cubit_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baktaz_flutter/features/account/domain/cubit/profile/profile_cubit.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../account/utils/generated_mocks.dart';

@GenerateMocks([IAccountRepository, IDeviceInfoRepository, FailureHandler])
void main() {
  late ProfileCubit cubit;
  late MockIAccountRepository mockRepo;
  late MockIDeviceInfoRepository mockDeviceRepo;
  late MockFailureHandler mockHandler;

  final Profile mockProfile = Profile(
    firstName: ValueName('Juan'),
    lastName: ValueName('Dela Cruz'),
    username: ValueName('juandelacruz'),
    gender: serverpod.Gender.male,
  );

  setUp(() {
    mockRepo = MockIAccountRepository();
    mockDeviceRepo = MockIDeviceInfoRepository();
    mockHandler = MockFailureHandler();
  });

  group('updateProfile', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits updated profile on success',
      build: () {
        when(mockRepo.updateProfile(
          firstName: 'Juan',
          lastName: 'Dela Cruz',
          mobileNumber: anyNamed('mobileNumber'),
          birthday: anyNamed('birthday'),
          gender: anyNamed('gender'),
          avatarUrl: anyNamed('avatarUrl'),
        )).thenAnswer((_) async => right(mockProfile));
        return ProfileCubit(mockRepo, mockDeviceRepo, mockHandler);
      },
      act: (cubit) async => cubit.updateProfile(firstName: 'Juan', lastName: 'Dela Cruz'),
      expect: () => [
        isA<ProfileState>().having((s) => s.queryStatus, 'loading', isA<QueryLoading>()),
        isA<ProfileState>().having((s) => s.profile, 'updated profile', mockProfile),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits error and triggers FailureHandler on failure',
      build: () {
        when(mockRepo.updateProfile(
          firstName: anyNamed('firstName'),
          lastName: anyNamed('lastName'),
        )).thenAnswer((_) async => left(const ServerFailure(500)));
        return ProfileCubit(mockRepo, mockDeviceRepo, mockHandler);
      },
      act: (cubit) async => cubit.updateProfile(firstName: 'Fail', lastName: 'Test'),
      expect: () => [
        isA<ProfileState>().having((s) => s.queryStatus, 'loading', isA<QueryLoading>()),
        isA<ProfileState>().having((s) => s.queryStatus, 'failed', isA<QueryFailure>()),
      ],
      verify: (_) => verify(mockHandler.handleFailure(any)).called(1),
    );
  });

  group('initialize', () {
    blocTest<ProfileCubit, ProfileState>(
      'loads profile on initialize',
      build: () {
        when(mockRepo.getProfile()).thenAnswer((_) async => right(mockProfile));
        return ProfileCubit(mockRepo, mockDeviceRepo, mockHandler);
      },
      act: (cubit) => cubit.initialize(),
      expect: () => [
        isA<ProfileState>().having((s) => s.queryStatus, 'loading', isA<QueryLoading>()),
        isA<ProfileState>().having((s) => s.profile, 'loaded profile', mockProfile),
      ],
    );
  });
}
```

---

## 5. Flutter Widget & Golden Tests

**Location:** `baktaz_flutter/test/widget/account/profile_screen_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:baktaz_flutter/features/account/presentation/views/screens/my_account/profile_screen.dart';
import 'package:baktaz_flutter/features/account/domain/cubit/profile/profile_cubit.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';

import '../utils/generated_mocks.dart';

void main() {
  group('ProfileScreen', () {
    late MockProfileCubit mockCubit;
    late Profile mockProfile;

    setUp(() {
      mockCubit = MockProfileCubit();
      mockProfile = Profile(
        firstName: ValueName('Juan'),
        lastName: ValueName('Dela Cruz'),
        username: ValueName('juandelacruz'),
        gender: serverpod.Gender.male,
        email: EmailAddress('juan@example.com'),
        imageUrl: null,
      );

      when(mockCubit.state).thenReturn(ProfileState(
        queryStatus: const QueryStatus.done(),
        profile: mockProfile,
      ));
      when(() => mockCubit.close()).thenAnswer((_) async {});
    });

    testWidgets('displays firstName, lastName, username, email', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProfileCubit>.value(
            value: mockCubit,
            child: const ProfileScreen(),
          ),
        ),
      );

      expect(find.text('Juan'), findsOneWidget);
      expect(find.text('Dela Cruz'), findsOneWidget);
      expect(find.text('@juandelacruz'), findsOneWidget);
      expect(find.text('juan@example.com'), findsOneWidget);
    });

    testWidgets('shows social provider list', (tester) async {
      when(mockCubit.state).thenReturn(ProfileState(
        queryStatus: const QueryStatus.done(),
        profile: mockProfile,
        linkedProviders: ['google'],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProfileCubit>.value(
            value: mockCubit,
            child: const ProfileScreen(),
          ),
        ),
      );

      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Linked'), findsOneWidget);
    });
  });
}
```

**Location:** `baktaz_flutter/test/widget/account/account_page_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:baktaz_flutter/features/account/presentation/views/pages/account_page.dart';
import 'package:baktaz_flutter/features/account/domain/cubit/account_cubit.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';

import '../utils/generated_mocks.dart';

void main() {
  group('AccountPage', () {
    late MockAccountCubit mockCubit;
    late AccountSummary mockSummary;

    setUp(() {
      mockCubit = MockAccountCubit();
      mockSummary = AccountSummary(
        name: ValueName('Juan Dela Cruz'),
        balance: Money(1000),
        connect: Number(100),
        imageUrl: null,
        memberSince: LocalDateTime(DateTime(2024, 1, 15)),
        totalChallengeSteps: Number(142500),
        challengesJoined: Number(12),
        challengesWon: Number(4),
        winRatePercentage: Number(33.3),
      );

      when(mockCubit.state).thenReturn(AccountState(
        queryStatus: const QueryStatus.done(),
        accountSummary: mockSummary,
      ));
      when(() => mockCubit.close()).thenAnswer((_) async {});
    });

    testWidgets('displays avatar, name, username, memberSince', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AccountCubit>.value(
            value: mockCubit,
            child: const AccountPage(),
          ),
        ),
      );

      expect(find.text('Juan Dela Cruz'), findsOneWidget);
      expect(find.text('@juandelacruz'), findsOneWidget);
      expect(find.textContaining('Member since'), findsOneWidget);
    });

    testWidgets('displays ChallengeStatsGrid with 4 columns', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AccountCubit>.value(
            value: mockCubit,
            child: const AccountPage(),
          ),
        ),
      );

      expect(find.text('142,500'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('33.3%'), findsOneWidget);
    });
  });
}
```

**Location:** `baktaz_flutter/test/widget/auth/registration_screen_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:baktaz_flutter/features/auth/presentation/views/registration_screen.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';

import '../utils/generated_mocks.dart';

void main() {
  group('RegistrationScreen', () {
    late MockLoginCubit mockCubit;

    setUp(() {
      mockCubit = MockLoginCubit();
      when(mockCubit.state).thenReturn(LoginState.idle());
      when(() => mockCubit.close()).thenAnswer((_) async {});
    });

    testWidgets('shows firstName, lastName, username fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LoginCubit>.value(
            value: mockCubit,
            child: const RegistrationScreen(email: 'test@example.com', registrationToken: 'token123'),
          ),
        ),
      );

      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      // Verify username auto-filled
      expect(find.byWidgetPredicate((widget) => widget is TextField && widget.controller?.text == 'test'), findsOneWidget);
    });
  });
}
```

---

## 6. Golden Tests

**Location:** `baktaz_flutter/test/widget/account/goldens/profile_screen_macos/`

```bash
# Generate/update goldens
cd baktaz_flutter
fvm flutter test test/widget/account/profile_screen_test.dart --update-goldens
fvm flutter test test/widget/account/account_page_test.dart --update-goldens
```

---

## 7. Verification Commands

```bash
# Full analysis
rtk make analyze

# All tests
rtk make test_flutter

# Server integration tests (requires Docker)
cd baktaz_server
fvm dart test test/integration/features/account/ --concurrency=1

# Coverage
cd baktaz_flutter
flutter test --coverage
lcov --list coverage/lcov.info
```

---

## Coverage Targets

| Type | Target |
|---|---|
| Overall | ≥ 80% |
| Cubits/Repositories/Utils | 100% |
| Widgets | ≥ 80% |
