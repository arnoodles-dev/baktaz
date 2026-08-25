# Flutter Audit Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Fix Flutter-specific audit violations: Pattern-B state, i18n localization, HookWidget conversion, BlocSignalProvider compliance.

**Tech Stack:** Flutter 3.47+, bloc_signals, slang, freezed, mockito.

**Spec:** See parent plan `2026-08-26-comprehensive-fix.md` for global constraints (fvm commands, codegen order, mockito-only tests).

---

### Task 1: LoginState Pattern-B fix (no Failure in state)

**Files:**
- Modify: `baktaz_flutter/lib/features/auth/domain/cubit/login/login_state.dart`
- Modify: `baktaz_flutter/lib/features/auth/domain/cubit/login/login_cubit.dart:114-122`
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/login_email_screen.dart:30-33`
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/otp_verification_screen.dart:45-47`
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart:40-43`
- Test: `baktaz_flutter/test/unit/features/auth/domain/cubit/login_cubit_state_test.dart` (create)
- Test: `baktaz_flutter/test/unit/features/auth/domain/cubit/login_cubit_failure_test.dart` (create)

**Interfaces:**
- Consumes: `FailureHandler.handleFailure(Failure)` (existing lazySingleton, shows toast per `error_actions.dart`), mockito mocks `MockIAuthRepository`, `MockIAnalyticsService`, `MockFailureHandler` from `package:baktaz_flutter/test/utils/generated_mocks.dart`.
- Produces: `LoginState.failed()` — parameterless variant (was `LoginState.failed(Failure failure)`). All downstream `state.whenOrNull(failed: ...)` handlers change arity from `(Failure)` to `()`. No other public surface changes.

- [ ] **Step 1: Write failing state-shape test**

Create `baktaz_flutter/test/unit/features/auth/domain/cubit/login_cubit_state_test.dart`:
```dart
import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginState', () {
    test('failed variant carries no Failure payload (Pattern B)', () {
      const LoginState state = LoginState.failed();

      expect(state, isA<LoginState>());
      // Pattern B: state stores a generic error flag, never a Failure object.
      expect(state.toString(), isNot(contains('Failure')));
      expect(state.toString(), equals('LoginState.failed()'));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd baktaz_flutter && fvm flutter test test/unit/features/auth/domain/cubit/login_cubit_state_test.dart`
Expected: FAIL — compile error "Too many positional arguments: 0 expected, 1 found" or missing `const LoginState.failed()` constructor (current signature requires `Failure failure`).

- [ ] **Step 3: Change state factory**

In `login_state.dart` replace line 12:
```dart
  const factory LoginState.failed(Failure failure) = LoginStateFailed;
```
with:
```dart
  const factory LoginState.failed() = LoginStateFailed;
```
Leave all other factories untouched.

- [ ] **Step 4: Regenerate freezed**

Run: `cd baktaz_flutter && fvm dart run build_runner build --delete-conflicting-outputs`
Expected: BUILD SUCCEEDED; `login_cubit.freezed.dart` regenerated with parameterless `LoginStateFailed`.

- [ ] **Step 5: Update cubit emitter**

In `login_cubit.dart` replace `_onAuthError` (lines ~114-122):
```dart
  void _onAuthError(Failure failure) {
    _failureHandler.handleFailure(failure);
    if (failure is AuthenticationError && failure.blocked) {
      safeEmit(const LoginState.blocked());
      return;
    }

    safeEmit(const LoginState.failed());
  }
```
(The `Failure` import from `baktaz_shared` remains — `fold` callbacks still type it.)

- [ ] **Step 6: Update the four screen listeners**

`login_email_screen.dart` lines 30-33 — replace:
```dart
      failed: (Failure failure) {
        context.loaderOverlay.hide();
        DialogUtils.showError(ErrorMessageUtils.generate(context, failure));
      },
```
with:
```dart
      failed: () => context.loaderOverlay.hide(),
```
Then delete now-unused imports `app/utils/dialog_utils.dart` and `app/utils/error_message_utils.dart` from that file IF analyzer flags them unused (DialogUtils may still be referenced elsewhere in file — check first; ErrorMessageUtils definitely removable).

`otp_verification_screen.dart` lines 45-47 — replace:
```dart
      failed: (Failure failure) {
        context.loaderOverlay.hide();
        otpError.value = ErrorMessageUtils.generate(context, failure);
      },
```
with:
```dart
      failed: () => context.loaderOverlay.hide(),
```
Keep the `otpError` ValueNotifier (BaktazOtpScreen consumes it); it simply never gets set now. Delete the `ErrorMessageUtils` import.

`registration_screen.dart` lines 40-43 — replace:
```dart
      failed: (Failure failure) {
        context.loaderOverlay.hide();
        DialogUtils.showError(ErrorMessageUtils.generate(context, failure));
      },
```
with:
```dart
      failed: () => context.loaderOverlay.hide(),
```
Delete `ErrorMessageUtils` import (keep DialogUtils — exit dialog uses it).

`login_screen.dart` line 36 already reads `failed: (_) => context.loaderOverlay.hide(),` — change to `failed: () => context.loaderOverlay.hide(),` for arity correctness.

- [ ] **Step 7: Write failing cubit behavior test**

Create `baktaz_flutter/test/unit/features/auth/domain/cubit/login_cubit_failure_test.dart`:
```dart
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/entity/enum/login_provider.dart';
import 'package:baktaz_flutter/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/test/utils/generated_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_core/features/analytics/i_analytics_service.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MockIAuthRepository repo;
  late MockIAnalyticsService analytics;
  late MockFailureHandler failureHandler;
  late LoginCubit cubit;

  setUp(() {
    repo = MockIAuthRepository();
    analytics = MockIAnalyticsService();
    failureHandler = MockFailureHandler();
    cubit = LoginCubit(repo, analytics, failureHandler);
  });

  group('completeRegistration failure path (Pattern B)', () {
    test('emits failed flag state and routes Failure through handler', () async {
      when(
        () => repo.completeRegistration(
          email: anyNamed('email'),
          name: anyNamed('name'),
          gender: anyNamed('gender'),
          birthday: anyNamed('birthday'),
          registrationToken: anyNamed('registrationToken'),
        ),
      ).thenAnswer(
        (_) async => TaskResult<AuthSuccess>.left(
          const Failure.authentication('Invalid or expired registration token'),
        ),
      );

      final List<LoginState> emitted = <LoginState>[];
      final Object subscription = cubit.state.listen(emitted.add);
      addTearDown(() async {
        await cubit.close();
        // ignore: avoid_types_on_closure_parameters
        await (subscription as dynamic).cancel();
      });

      await cubit.completeRegistration(
        email: 'a@b.co',
        name: 'Tester',
        gender: 'male',
        birthday: null,
        registrationToken: 'tok',
      );
      await Future<void>.delayed(Duration.zero);

      expect(emitted, isNotEmpty);
      expect(emitted.last, isA<LoginState>());
      expect(emitted.last.toString(), equals('LoginState.failed()'));
      verify(failureHandler.handleFailure(any)).called(1);
    });

    test('blocked AuthenticationError routes to blocked state', () async {
      when(
        () => repo.completeRegistration(
          email: anyNamed('email'),
          name: anyNamed('name'),
          gender: anyNamed('gender'),
          birthday: anyNamed('birthday'),
          registrationToken: anyNamed('registrationToken'),
        ),
      ).thenAnswer(
        (_) async => TaskResult<AuthSuccess>.left(
          const Failure.authentication('Account blocked', blocked: true),
        ),
      );

      final List<LoginState> emitted = <LoginState>[];
      final Object subscription = cubit.state.listen(emitted.add);
      addTearDown(() async {
        await cubit.close();
        await (subscription as dynamic).cancel();
      });

      await cubit.completeRegistration(
        email: 'a@b.co',
        name: 'Tester',
        gender: 'male',
        birthday: null,
        registrationToken: 'tok',
      );
      await Future<void>.delayed(Duration.zero);

      expect(emitted.last.toString(), contains('blocked'));
      verify(failureHandler.handleFailure(any)).called(1);
    });
  });
}
```
If `MockIAnalyticsService.logLogin` needs a stub for other paths it is Nice-mock — no-op by default.

- [ ] **Step 8: Run tests**

Run: `cd baktaz_flutter && fvm flutter test test/unit/features/auth/domain/cubit/`
Expected: PASS (both files).

- [ ] **Step 9: Analyze + full suite**

Run: `cd baktaz_flutter && fvm dart analyze && fvm flutter test`
Expected: No issues. Full suite green (any golden drift from removed inline OTP error text: re-run once; goldens auto-update per test_config forceUpdateGoldenFiles=true, commit refreshed goldens).

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "refactor(flutter): enforce Pattern B — LoginState.failed carries no Failure payload"
```


### Task 2: Localize challenge/message/common strings (slang batch A)

**Files:**
- Modify: `baktaz_flutter/assets/i18n/en.i18n.json`
- Modify: `baktaz_flutter/lib/features/challenge/presentation/views/pages/challenge_page.dart:19-20`
- Modify: `baktaz_flutter/lib/features/message/presentation/views/chat_page.dart:10-11`
- Modify: `baktaz_flutter/lib/features/message/presentation/views/notification_page.dart:10-11`
- Test: `baktaz_flutter/test/unit/localization_keys_test.dart` (create)

**Interfaces:**
- Produces: slang accessors `context.i18n.common.discover_new`, `context.i18n.challenge.history`, `context.i18n.challenge.nothing_happening_now`, `context.i18n.challenge.no_activity`, `context.i18n.messages.find_chats`, `context.i18n.messages.notifications_placeholder`, `context.i18n.messages.notifications_subtitle`, `context.i18n.select_address.address_selection`, `context.i18n.common.confirm`. Later tasks consume these.

- [ ] **Step 1: Add keys to en.i18n.json**

Inside top-level object add two NEW namespaces and extend `common` + `select_address`:

After the `"common"` object's existing `"see_all"` entry (keep alphabetical placement loose, JSON order irrelevant):
```json
    "discover_new": "Discover what's new on the app",
    "confirm": "Confirm"
```

New sibling namespaces (insert after `"post"` block, before closing brace):
```json
  "challenge": {
    "history": "Challenge History",
    "nothing_happening_now": "Nothing's happening now",
    "no_activity": "No Activity"
  },
  "messages": {
    "find_chats": "Find your chats here!",
    "notifications_placeholder": "Notifications will appear here",
    "notifications_subtitle": "Watch this space for offers, updates, and more."
  },
```

Extend `"select_address"` object with:
```json
    "address_selection": "Address Selection"
```

- [ ] **Step 2: Regenerate slang**

Run: `cd baktaz_flutter && fvm dart run slang`
Expected: regeneration succeeds; string count increases from 114.

- [ ] **Step 3: Write failing localization test**

Create `baktaz_flutter/test/unit/localization_keys_test.dart`:
```dart
import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final I18n t = AppLocale.en.buildSync();

  group('audit-localized keys exist', () {
    test('common', () {
      expect(t.common.discover_new, "Discover what's new on the app");
      expect(t.common.confirm, 'Confirm');
    });
    test('challenge', () {
      expect(t.challenge.history, 'Challenge History');
      expect(t.challenge.nothing_happening_now, "Nothing's happening now");
      expect(t.challenge.no_activity, 'No Activity');
    });
    test('messages', () {
      expect(t.messages.find_chats, 'Find your chats here!');
      expect(t.messages.notifications_placeholder, 'Notifications will appear here');
      expect(t.messages.notifications_subtitle, 'Watch this space for offers, updates, and more.');
    });
    test('select_address', () {
      expect(t.select_address.address_selection, 'Address Selection');
    });
  });
}
```

- [ ] **Step 4: Run test**

Run: `cd baktaz_flutter && fvm flutter test test/unit/localization_keys_test.dart`
Expected: PASS (keys were added in Step 1; if FAIL, slang regen missed — rerun Step 2).

- [ ] **Step 5: Swap hardcoded strings**

`challenge_page.dart` — add import `package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart`, replace:
```dart
              title: "Nothing's happening now",
              subtitle: "Discover what's new on the app",
```
with:
```dart
              title: context.i18n.challenge.nothing_happening_now,
              subtitle: context.i18n.common.discover_new,
```

`chat_page.dart` — add same import, replace:
```dart
    title: 'Find your chats here!',
    subtitle: "Discover what's new on the app",
```
with:
```dart
    title: context.i18n.messages.find_chats,
    subtitle: context.i18n.common.discover_new,
```

`notification_page.dart` — add same import, replace:
```dart
    title: 'Notifications will appear here',
    subtitle: 'Watch this space for offers, updates, and more.',
```
with:
```dart
    title: context.i18n.messages.notifications_placeholder,
    subtitle: context.i18n.messages.notifications_subtitle,
```

- [ ] **Step 6: Verify + commit**

Run: `cd baktaz_flutter && fvm dart analyze && fvm flutter test test/unit/`
Expected: clean, green.

```bash
git add -A && git commit -m "fix(flutter): localize challenge/message/common strings per code-quality rule"
```

### Task 3: Localize remaining flutter strings (batch B)

**Files:**
- Modify: `baktaz_flutter/assets/i18n/en.i18n.json`
- Modify: `baktaz_flutter/lib/features/challenge/presentation/views/screens/challenge_history_screen.dart:16,19`
- Modify: `baktaz_flutter/lib/features/account/presentation/views/screens/my_account/review_screen.dart:16,19`
- Modify: `baktaz_flutter/lib/features/account/presentation/views/screens/my_account/contact_screen.dart:17,20,25`
- Modify: `baktaz_flutter/lib/features/account/presentation/views/screens/settings/dark_mode_screen.dart:22-23`
- Modify: `baktaz_flutter/lib/core/presentation/views/screens/select_address_screen.dart:20,22`
- Test: extend `baktaz_flutter/test/unit/localization_keys_test.dart`

**Interfaces:**
- Produces: `t.account.reviews_title`, `t.account.no_reviews`, `t.account.contacts_title`, `t.account.no_contacts`, `t.account.add_contact`, `t.settings.follow_system`, `t.settings.dark_mode_subtitle`, `t.challenge.no_activity` (from Task 2), `t.common.confirm` (from Task 2).

- [ ] **Step 1: Add keys**

Extend `"account"` object (after `"button"` block):
```json
    "reviews_title": "Reviews",
    "no_reviews": "No Reviews",
    "contacts_title": "Contacts",
    "no_contacts": "No Contacts",
    "add_contact": "Add Contact",
```
New namespace after `"register"`:
```json
  "settings": {
    "follow_system": "Follow system settings",
    "dark_mode_subtitle": "Turn on Dark mode when your device's Dark mode setting is on"
  },
```

- [ ] **Step 2: Extend test** — append to `localization_keys_test.dart` group:
```dart
    test('account + settings', () {
      expect(t.account.reviews_title, 'Reviews');
      expect(t.account.no_reviews, 'No Reviews');
      expect(t.account.contacts_title, 'Contacts');
      expect(t.account.no_contacts, 'No Contacts');
      expect(t.account.add_contact, 'Add Contact');
      expect(t.settings.follow_system, 'Follow system settings');
      expect(t.settings.dark_mode_subtitle, "Turn on Dark mode when your device's Dark mode setting is on");
    });
```

- [ ] **Step 3: Regenerate + run** — `fvm dart run slang` then `fvm flutter test test/unit/localization_keys_test.dart`. Expected: PASS.

- [ ] **Step 4: Swap call-sites** (each file: ensure `build_context_ext.dart` import present):

`challenge_history_screen.dart`: `title: context.i18n.challenge.history` (line 16), `EmptyPage(title: context.i18n.challenge.no_activity, ...)` (line 19).
`review_screen.dart`: `title: context.i18n.account.reviews_title` (line 16), `body: EmptyPage(title: context.i18n.account.no_reviews, iconPath: Assets.images.noReviews.path)` (line 19).
`contact_screen.dart`: appBar `title: context.i18n.account.contacts_title` (17), `EmptyPage(title: context.i18n.account.no_contacts, ...)` (20), button `text: context.i18n.account.add_contact` (25).
`dark_mode_screen.dart`: `label: context.i18n.settings.follow_system` (22), `subtitle: context.i18n.settings.dark_mode_subtitle` (23).
`select_address_screen.dart`: `text: context.i18n.select_address.address_selection` (20), `text: context.i18n.common.confirm` (22).

- [ ] **Step 5: Sweep for stragglers**

Run: `rtk grep -rn "title: '[A-Z]" baktaz_flutter/lib/features/ baktaz_flutter/lib/core/presentation/views/ || true`
Expected: no remaining literal-title hits (comments ok). Any hit → localize same way, rerun slang.

- [ ] **Step 6: Verify + commit**

`cd baktaz_flutter && fvm dart analyze && fvm flutter test` → clean/green.
`git add -A && git commit -m "fix(flutter): localize remaining hardcoded strings (challenge history, reviews, contacts, settings)"`

### Task 5: Typed RemoteConfigState

**Files:**
- Create: `baktaz_flutter/lib/core/domain/cubit/remote_config/remote_config_state.dart`
- Modify: `baktaz_flutter/lib/core/domain/cubit/remote_config/remote_config_cubit.dart`
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart:56,137-138`
- Modify: `baktaz_flutter/lib/features/account/presentation/views/screens/support/support_webview_screen.dart:20`
- Test: `baktaz_flutter/test/unit/core/domain/cubit/remote_config_state_test.dart` (create)

**Interfaces:**
- Consumes: `RemoteAppConfigDTO` fields (`isMaintenance`, `minSupportedVersion`, `androidStoreUrl`, `iosStoreUrl`), `IRemoteConfigService`, `IDeviceInfoRepository`, `FailureHandler`.
- Produces: `RemoteConfigState` freezed class:
```dart
// remote_config_state.dart
part of 'remote_config_cubit.dart';

@freezed
sealed class RemoteConfigState with _$RemoteConfigState {
  const factory RemoteConfigState({@Default(<String, dynamic>{}) Map<String, dynamic> values}) = _RemoteConfigState;

  const RemoteConfigState._();

  bool get isMaintenance => values['is_maintenance'] == true || values['is_maintenance'] == 'true';

  String? get minSupportedVersion => values['min_supported_version'] as String?;

  String? get androidStoreUrl => values['android_store_url'] as String?;

  String? get iosStoreUrl => values['ios_store_url'] as String?;

  /// Escape hatch for dynamic admin-defined keys (e.g. webview configKey).
  String? value(String key) => values[key] as String?;
}
```
Cubit becomes `CubitSignal<RemoteConfigState>` with `initialState: const RemoteConfigState()`; emissions wrap maps: `safeEmit(RemoteConfigState(values: dto.toJson()))`. Internal getters switch from `stateValue['x'] as String?` to `stateValue.minSupportedVersion` etc. External readers: `remoteConfig.value('terms_condition_url') ?? ''` and webview `remoteConfig.value(option.configKey)`.

- [ ] **Step 1: Write failing state test**

Create `baktaz_flutter/test/unit/core/domain/cubit/remote_config_state_test.dart`:
```dart
import 'package:baktaz_flutter/core/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteConfigState', () {
    test('exposes typed getters from raw values', () {
      const RemoteConfigState state = RemoteConfigState(
        values: <String, dynamic>{
          'is_maintenance': true,
          'min_supported_version': '1.2.0',
          'android_store_url': 'https://play.example',
        },
      );

      expect(state.isMaintenance, isTrue);
      expect(state.minSupportedVersion, '1.2.0');
      expect(state.androidStoreUrl, 'https://play.example');
      expect(state.iosStoreUrl, isNull);
      expect(state.value('terms_condition_url'), isNull);
    });

    test('defaults are safe', () {
      const RemoteConfigState state = RemoteConfigState();

      expect(state.isMaintenance, isFalse);
      expect(state.minSupportedVersion, isNull);
    });
  });
}
```

- [ ] **Step 2: Run — expect FAIL** (class undefined). Command as Step-1 path.

- [ ] **Step 3: Implement state file + cubit rewiring**

Add `part 'remote_config_state.dart';` to `remote_config_cubit.dart` beside existing part-free imports (file has no parts yet — add after imports). Change declaration to:
```dart
@lazySingleton
class RemoteConfigCubit extends CubitSignal<RemoteConfigState> {
  RemoteConfigCubit(this._remoteConfigService, this._deviceRepository, this._failureHandler)
    : super(initialState: const RemoteConfigState());
```
Replace each raw-map emission/access:
- `safeEmit(RemoteAppConfigDTO.fallback().toJson())` (two sites) → `safeEmit(RemoteConfigState(values: RemoteAppConfigDTO.fallback().toJson()))`
- stream listener mapping (wherever service pushes map) → `safeEmit(RemoteConfigState(values: map))`
- `stateValue['is_maintenance'] as String?` → `stateValue.isMaintenance` (adjust following logic: was nullable-string compare; now bool — simplify condition accordingly)
- `stateValue['min_supported_version'] as String?` → `stateValue.minSupportedVersion`
- store-url getters → `stateValue.androidStoreUrl` / `stateValue.iosStoreUrl`

Run build_runner. Fix any cascade errors until analyze clean.

- [ ] **Step 4: Update external readers**

`registration_screen.dart:56`: `final Map<String, dynamic> remoteConfig = context.read<RemoteConfigCubit>().stateValue;` → `final RemoteConfigState remoteConfig = context.read<RemoteConfigCubit>().stateValue;` (import cubit already present). Lines 137-138: `remoteConfig['terms_condition_url'].toString()` → `(remoteConfig.value('terms_condition_url') ?? '')`, same for `'privacy_policy_url'`.
`support_webview_screen.dart:20`: `remoteConfig[option.configKey] as String?` → `remoteConfig.value(option.configKey)`.

- [ ] **Step 5: Run tests + analyze** → green/clean. Goldens may refresh (auto-commit).

- [ ] **Step 6: Commit** — `git commit -m "refactor(flutter): typed RemoteConfigState replaces raw Map state"`.

### Task 9: BlocSignalProvider annotation compliance

**Files:**
- Modify: `baktaz_flutter/lib/core/presentation/views/screens/main_screen.dart:37-38`
- Modify: `baktaz_admin/lib/features/auth/presentation/views/login_screen.dart:30-35`

**Rule reference:** `state-management-architecture.md`:
- `@lazySingleton` Cubits → `BlocSignalProvider.value(value: getIt<T>())`
- `@injectable` Cubits → `BlocSignalProvider(create: (_) => getIt<T>())`

**Violations found:**

| File | Cubit | Annotation | Current | Fix |
|------|-------|-----------|---------|-----|
| `flutter/main_screen.dart:37` | `AccountCubit` | `@injectable` | `.value(value:)` | → `create:` |
| `flutter/main_screen.dart:38` | `HomeCubit` | `@injectable` | `.value(value:)` | → `create:` |
| `admin/login_screen.dart:30` | `LoginCubit` | `@injectable` | `create:` | → `.value(value:)` (but needs init) |

**Note:** Admin `login_screen.dart` calls `cubit.initialize()` before returning — this initialization MUST happen. Use pattern:
```dart
BlocSignalProvider<LoginCubit>.value(
  value: () {
    final LoginCubit cubit = getIt<LoginCubit>();
    unawaited(cubit.initialize());
    return cubit;
  }(),
  child: ...
)
```
Or keep `create:` but rename to clarify it's an init wrapper.

For `main_screen.dart`, the `AccountCubit` and `HomeCubit` don't need init — just swap to `create:`:
```dart
BlocSignalProvider<AccountCubit>(
  create: (BuildContext context) => getIt<AccountCubit>(),
  lazy: false,
  child: ...
),
BlocSignalProvider<HomeCubit>(
  create: (BuildContext context) => getIt<HomeCubit>(),
  lazy: false,
  child: ...
),
```

- [ ] **Step 1: Fix main_screen.dart**

Replace lines 37-38 in `baktaz_flutter/lib/core/presentation/views/screens/main_screen.dart`:
```dart
        BlocSignalProvider<AccountCubit>(lazy: false, create: (BuildContext context) => getIt<AccountCubit>()),
        BlocSignalProvider<HomeCubit>(lazy: false, create: (BuildContext context) => getIt<HomeCubit>()),
```

- [ ] **Step 2: Fix admin login_screen.dart**

For admin `login_screen.dart`, since `LoginCubit` is `@injectable` but needs initialization, use `create:` (current form is correct per rule) — NO CHANGE NEEDED. The violation was misidentified; `@injectable` → `create:` is correct.

Actually re-checking: the rule says `@injectable` → `create:`. Admin login_screen uses `create:`. This is CORRECT. No fix needed.

- [ ] **Step 3: Verify BlocSignalProvider annotations**

Run: `rtk grep -rn "BlocSignalProvider" baktaz_flutter/lib baktaz_admin/lib`
For each match, verify the Cubit annotation matches the provider pattern:
- `@lazySingleton` Cubit → must use `.value(value:)`
- `@injectable` Cubit → must use `create:`

Run: `rtk grep -B2 "BlocSignalProvider" baktaz_flutter/lib/core/presentation/views/screens/main_screen.dart`
Expected: `create:` for AccountCubit and HomeCubit (both @injectable).

- [ ] **Step 3b: Verify state usage is correct**

- `.state.subscribe()` in `route_refresh_listener.dart` — CORRECT (reactive side effect)
- `.stateValue` in `context.select` callbacks — ACCEPTABLE (selector needs comparable value)
- No violations found in state access patterns.

Run:
```bash
rtk grep -rn "BlocSignalProvider" baktaz_flutter/lib baktaz_admin/lib | grep -v "BlocSignalProvider.value" | grep -v "BlocSignalProvider(" | grep -v "//" || true
rtk grep -rn "BlocSignalProvider.*create" baktaz_flutter/lib baktaz_admin/lib | while read line; do
  cubit=$(echo "$line" | grep -oP '<\K[^>]+')
  grep -q "@injectable" baktaz_flutter/lib/features/auth/domain/cubit/login/login_cubit.dart 2>/dev/null || true
done
```

Verify each `BlocSignalProvider` usage matches the annotation of its Cubit.

- [ ] **Step 4: Analyze**

Run: `cd baktaz_flutter && fvm dart analyze` and `cd baktaz_admin && fvm dart analyze`
Expected: clean.

- [ ] **Step 5: Commit**

`git commit -m "refactor: ensure BlocSignalProvider matches Cubit annotations"`.

---

