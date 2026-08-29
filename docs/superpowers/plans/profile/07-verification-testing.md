# Task 7: Verification & Testing

**Files:**
- Create: `baktaz_flutter/test/unit/profile_cubit_test.dart`
- Create: `baktaz_flutter/test/unit/avatar_upload_service_test.dart`
- Create: `baktaz_flutter/test/widget/account/profile_screen_test.dart`
- Create: `baktaz_flutter/test/widget/account/account_page_test.dart`
- Create: `baktaz_flutter/test/widget/auth/registration_screen_test.dart`

**Interfaces:**
- Consumes: `ProfileCubit`, `ProfileScreen`, `AccountPage`, `RegistrationScreen`, `AccountCubit`, `LoginCubit`, `AvatarUploadService`
- Produces: Test suite verifying unit logic and UI golden rendering.

---

TDD principle: Implementation complete → Write tests → Run tests → Verify coverage ≥ 80% for widgets, 100% for Cubits/Repos.

---

- [ ] **Step 1: Write ProfileCubit unit tests (Pattern B - side effects only)**

Create `baktaz_flutter/test/unit/profile_cubit_test.dart`:
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baktaz_flutter/features/account/domain/cubit/profile/profile_cubit.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../utils/generated_mocks.dart';

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
      'emits error side-effect and returns to done status on failure (Pattern B)',
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
        isA<ProfileState>().having((s) => s.queryStatus, 'done', isA<QueryDone>()),
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

  group('getAvatarUploadUrl', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits avatarUploadUrl on success',
      build: () {
        when(mockRepo.getAvatarUploadUrl()).thenAnswer((_) async => right(
          serverpod.AvatarUploadUrl(
            uploadUrl: 'https://example.com/upload',
            permanentUrl: 'https://example.com/permanent',
            fileKey: 'avatars/123.webp',
            expiresAt: DateTime.now().add(Duration(minutes: 10)),
          ),
        ));
        return ProfileCubit(mockRepo, mockDeviceRepo, mockHandler);
      },
      act: (cubit) async => cubit.getAvatarUploadUrl(),
      expect: () => [
        isA<ProfileState>().having((s) => s.queryStatus, 'loading', isA<QueryLoading>()),
        isA<ProfileState>().having((s) => s.avatarUploadUrl, 'has upload url', isNotNull),
      ],
    );
  });

  group('loadLinkedProviders', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits linkedProviders on success',
      build: () {
        when(mockRepo.getLinkedProviders()).thenAnswer((_) async => right(['google']));
        return ProfileCubit(mockRepo, mockDeviceRepo, mockHandler);
      },
      act: (cubit) async => cubit.loadLinkedProviders(),
      expect: () => [
        isA<ProfileState>().having((s) => s.queryStatus, 'loading', isA<QueryLoading>()),
        isA<ProfileState>().having((s) => s.linkedProviders, 'has providers', ['google']),
      ],
    );
  });
}
```

---

- [ ] **Step 2: Write AvatarUploadService unit tests**

Create `baktaz_flutter/test/unit/avatar_upload_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:baktaz_flutter/features/account/data/service/avatar_upload_service.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

import '../utils/generated_mocks.dart';

void main() {
  group('AvatarUploadService', () {
    late AvatarUploadService service;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      service = AvatarUploadService();
    });

    test('uploads bytes to presigned URL and returns success on 200', () async {
      when(mockHttpClient.put(
        Uri.parse('https://example.com/upload'),
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => Response('', 200));

      final result = await AvatarUploadService().uploadAvatar(
        uploadUrl: 'https://example.com/upload',
        bytes: Uint8List.fromList([1, 2, 3]),
      ).run();

      expect(result.isRight(), isTrue);
    });

    test('returns Failure on non-200 status', () async {
      when(mockHttpClient.put(
        Uri.parse('https://example.com/upload'),
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => Response('', 400));

      final result = await AvatarUploadService().uploadAvatar(
        uploadUrl: 'https://example.com/upload',
        bytes: Uint8List.fromList([1, 2, 3]),
      ).run();

      expect(result.isLeft(), isTrue);
    });
  });
}
```

---

- [ ] **Step 2: Write ProfileScreen widget tests**

Create `baktaz_flutter/test/widget/account/profile_screen_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:baktaz_flutter/features/account/presentation/views/screens/my_account/profile_screen.dart';
import 'package:baktaz_flutter/features/account/domain/cubit/profile/profile_cubit.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';

import '../../utils/generated_mocks.dart';

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

    testWidgets('shows social provider list with green check for linked', (tester) async {
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

---

- [ ] **Step 3: Write AccountPage widget tests**

Create `baktaz_flutter/test/widget/account/account_page_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:baktaz_flutter/features/account/presentation/views/pages/account_page.dart';
import 'package:baktaz_flutter/features/account/domain/cubit/account_cubit.dart'
import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';

import '../../utils/generated_mocks.dart';

void main() {
  group('AccountPage', () {
    late MockAccountCubit mockCubit;
    late AccountSummary mockSummary;

    setUp(() {
      mockCubit = MockAccountCubit();
      mockSummary = AccountSummary(
        name: ValueName('Juan Dela Cruz'),
        firstName: ValueName('Juan'),
        lastName: ValueName('Dela Cruz'),
        username: ValueName('juandelacruz'),
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

---

- [ ] **Step 4: Write RegistrationScreen widget tests**

Create `baktaz_flutter/test/widget/auth/registration_screen_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:baktaz_flutter/features/auth/presentation/views/registration_screen.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';

import '../../utils/generated_mocks.dart';

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

- [ ] **Step 5: Run all tests and analysis**

Run:
```bash
cd /Users/Arnold/Projects/baktaz

# Analyze
rtk make analyze

# Unit tests
rtk make test_flutter

# Golden tests (if Alchemist configured)
cd baktaz_flutter
fvm flutter test test/widget/account/profile_screen_test.dart --update-goldens
fvm flutter test test/widget/account/account_page_test.dart --update-goldens
```

Expected: All lints pass, all tests PASS.

---

- [ ] **Step 6: Verify coverage targets**

Run:
```bash
cd baktaz_flutter
flutter test --coverage
lcov --list coverage/lcov.info
```

Expected:
- Overall: ≥ 80%
- Cubits/Repos: 100%
- Widgets: ≥ 80%

---

- [ ] **Step 7: Final Commit**

```bash
cd /Users/Arnold/Projects/baktaz
git add baktaz_flutter/test/
git commit -m "test(account): add unit and widget tests for ProfileCubit, AvatarUploadService, ProfileScreen, AccountPage, RegistrationScreen"
```
