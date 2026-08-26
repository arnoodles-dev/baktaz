# Flutter Audit Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Fix Flutter-specific audit violations: Pattern-B state, i18n localization, HookWidget conversion, BlocSignalProvider compliance.

**Tech Stack:** Flutter 3.47+, bloc_signals, slang, freezed, mockito.

**Spec:** See parent plan `2026-08-26-comprehensive-fix.md` for global constraints (fvm commands, codegen order, mockito-only tests).

---

### Task 1: LoginState Strict Pattern-B fix (remove failed state entirely, add side-effect union)

**Files:**
- Modify: `baktaz_flutter/lib/features/auth/domain/cubit/login/login_state.dart`
- Modify: `baktaz_flutter/lib/features/auth/domain/cubit/login/login_cubit.dart`
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/login_email_screen.dart`
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/otp_verification_screen.dart`
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart`
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/login_screen.dart`
- Test: `baktaz_flutter/test/unit/features/auth/domain/cubit/login_cubit_failure_test.dart` (replace)

**Interfaces:**
- Consumes: `FailureHandler.handleFailure(Failure)` (existing lazySingleton, shows toast per `error_actions.dart`), `BlocSignalPresentationMixin` from `baktaz_shared`, mockito mocks `MockIAuthRepository`, `MockIAnalyticsService`, `MockFailureHandler` from `package:baktaz_flutter/test/utils/generated_mocks.dart`.
- Produces: `LoginStateSideEffect` union with `onOtpError` variant; NO `LoginState.failed()` variant exists at all. `presentationStream` carries contextual OTP errors to screen listeners. All `failed:` arms removed from screens.

**Known bug fixed by this task:** Screens' old `failed:` arms called `DialogUtils.showError(ErrorMessageUtils.generate(...))` while FailureHandler ALSO showed toast → double display. Side-effect pattern eliminates duplication; handler owns global feedback exclusively.

- [ ] **Step 1: Rewrite LoginState — delete failed, add side-effect union**

In `login_state.dart`:
- DELETE `const factory LoginState.failed(Failure failure) = LoginStateFailed;` entirely.
- ADD side-effect union:
```dart
@freezed
sealed class LoginStateSideEffect with _$LoginStateSideEffect {
  const factory LoginStateSideEffect.onOtpError(String message) = LoginStateOtpError;
}
```
Remaining state union: `idle`, `codeSent`, `verifying`, `verified`, `registrationCompleted`, `success`, `blocked`. No `.failed()`.

- [ ] **Step 2: Regenerate freezed**

Run: `cd baktaz_flutter && fvm dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Update cubit — add BlocSignalPresentationMixin**

In `login_cubit.dart` add `with BlocSignalPresentationMixin<LoginStateSideEffect, LoginState>` (import from `baktaz_shared`; shared mixin exists at `baktaz_shared/lib/src/mixin/bloc_signal_presentation_mixin.dart`, API: `emitPresentation(Event event)`, `presentationStream`).

Replace `_onAuthError` with:
```dart
void _onAuthError(Failure failure) {
  _failureHandler.handleFailure(failure); // global toast via ErrorActions
  if (failure is AuthenticationError && failure.blocked) {
    safeEmit(const LoginState.blocked());
    return;
  }
  // Contextual inline error for OTP screen (side-effect, NOT state):
  emitPresentation(LoginStateOtpError(/* resolved message */));
}
```
Note for implementer: resolve exact message mechanism — pass Failure-derived message string (consistent with prior `ErrorMessageUtils.generate(context, failure)` behavior); if context unavailable in cubit, emit the Failure subtype and let listener map to text. Implementer decides with reviewer; document choice in PR.

(The `Failure` import from `baktaz_shared` remains — `fold` callbacks still type it.)

- [ ] **Step 4: Update screens — remove failed: arms**

`login_email_screen.dart`: DELETE entire `failed:` arm; remove `ErrorMessageUtils` import; check `DialogUtils` still used elsewhere in file before removing.

`otp_verification_screen.dart`: swap listener wiring to presentation stream (use `BlocSignalPresentationListener` from `baktaz_shared/lib/src/mixin/bloc_signal_presentation_listener.dart` or subscribe cubit `presentationStream`); KEEP `otpError` ValueNotifier (screen-local UI state, Pattern-B-safe); feed it from `LoginStateOtpError` events; clear on resend/verify actions as today. Remove `ErrorMessageUtils` import.

`registration_screen.dart`: DELETE `failed:` arm; remove `ErrorMessageUtils` import.

`login_screen.dart`: DELETE `failed:` arm only (keep DialogUtils — exit dialog uses it).

`baktaz_otp_screen.dart`: NO change (already accepts `otpError` param).

- [ ] **Step 5: Write behavior tests**

Replace `login_cubit_failure_test.dart` with:
1. `verify(failureHandler.handleFailure(any)).called(1)` on auth error
2. Subscribe real `presentationStream` — expect one `LoginStateOtpError` event
3. Emitted states remain initial `idle` — cubit emits NOTHING on failure
4. Blocked path intact: `AuthenticationError(blocked: true)` → `LoginState.blocked()` emitted, handler called once
NO `toString()` assertions anywhere (no suite precedent; variant deleted).

- [ ] **Step 6: Run tests + analyze**

Run: `cd baktaz_flutter && fvm flutter test test/unit/features/auth/domain/cubit/ && fvm dart analyze`
Expected: PASS.

- [ ] **Step 7: Commit**

`git commit -m "refactor(flutter): enforce strict Pattern B — remove LoginState.failed, add OTP side-effect"`

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

**Step 1: Enumerate all BlocSignalProvider sites (~25 across baktaz_flutter + baktaz_admin)**

Run: `rtk grep -rn "BlocSignalProvider" baktaz_flutter/lib baktaz_admin/lib`
Expected: ~32 matches (MultiBlocSignalProvider also counts as provider site).

Build compliance table with columns: file:line | Cubit | DI annotation (@injectable/@lazySingleton) | required provider form (`.value(getIt<T>())` for @lazySingleton; `create: (_) => getIt<T>()` for @injectable) | compliant Y/N

Known suspicious rows to investigate:
| file:line | Cubit | annotation | current | required | compliant? |
|---|---|---|---|---|---|
| `flutter/main_screen.dart:37` | `AccountCubit` | `@injectable` (confirmed) | `create:` | `create:` | ✅ |
| `flutter/main_screen.dart:38` | `HomeCubit` | `@injectable` (unverified — confirm with grep) | `create:` | `create:` | ? |
| `flutter/app.dart:25-34` | `ThemeCubit` | `@lazySingleton` (verify) | `.value(getIt<ThemeCubit>())` | `.value` | ? |
| `flutter/app.dart:27` | `AppLifeCycleCubit` | `@lazySingleton` (verify) | `.value` | `.value` | ? |
| `flutter/app.dart:28` | `HidableCubit` | `@lazySingleton` (verify) | `.value` | `.value` | ? |
| `flutter/app.dart:31` | `RemoteConfigCubit` | `@lazySingleton` (verify) | `.value` | `.value` | ? |
| `flutter/app.dart:32` | `AuthCubit` | `@lazySingleton` (verify) | `.value` | `.value` | ? |
| `flutter/app.dart:33` | `AppCoreCubit` | `@lazySingleton` (verify) | `.value` | `.value` | ? |
| `flutter/app.dart:34` | `AppLocalizationCubit` | `@lazySingleton` (verify) | `.value` | `.value` | ? |
| `flutter/otp_verification_screen.dart:56` | `LoginCubit` | `@injectable` (confirmed) | `create:` | `create:` | ✅ |
| `flutter/login_email_screen.dart:43` | `LoginCubit` | `@injectable` | `create:` | `create:` | ✅ |
| `flutter/registration_screen.dart:72` | `LoginCubit` | `@injectable` | `create:` | `create:` | ✅ |
| `flutter/login_screen.dart:44` | `LoginCubit` | `@injectable` | `create:` | `create:` | ✅ |
| `flutter/profile_screen.dart:54` | `ProfileCubit` | (verify) | (check) | (check) | ? |
| `admin/app.dart:24-28` | `AppLocalizationCubit`, `AppCoreCubit`, `ThemeCubit`, `AuthCubit`, `HidableCubit` | (verify all @lazySingleton) | `.value` | `.value` | ? |
| `admin/login_screen.dart:30` | `LoginCubit` | `@injectable` (confirmed) | `create:` | `create:` | ✅ |
| `admin/content_screen.dart:26` | `ContentCubit` | (verify) | `.value` | ? | ? |
| `admin/dashboard_screen.dart:17` | `DashboardCubit` | (verify) | `create:` | ? | ? |
| `admin/remote_config_screen.dart:25` | `RemoteConfigCubit` | (verify) | `create:` | ? | ? |
| `admin/localization_screen.dart:23` | `LocalizationCubit` | (verify) | `create:` | ? | ? |

Reviewer verifies each row during execution.

**Step 2: Fix any non-compliant rows** — swap provider form to match annotation.

**Step 3: Analyze**

Run: `cd baktaz_flutter && fvm dart analyze` and `cd baktaz_admin && fvm dart analyze`
Expected: clean.

**Step 4: Commit**

`git commit -m "refactor: ensure BlocSignalProvider matches Cubit annotations"`.

---


## Final Verification (all tasks done)

1. Monorepo analyze: `melos exec -- fvm dart analyze` OR per-package loop.
2. Suites: `make test_flutter`; `make test_server` only if Postgres up.
3. DCM re-audit: confirm cyclomatic-complexity >20 and number-of-parameters >5 lists are empty (using bare `dcm analyze`).
4. Three-tier grep gates:
   - ✅ **BLOCKING** (must be zero before merge):
     - `rtk grep -rn "CubitSignal<Map" baktaz_flutter/lib` → zero
     - `rtk grep -rn "LoginState\.failed\(|LoginStateFailed" baktaz_flutter/lib` → zero
     - Failure fields inside state classes (reviewer check)
     - `handleFailure` not called before any state emission on error paths (reviewer check)
   - ⚠️ **FIX-BEFORE-CLOSE** (non-blocking but tracked): none in baktaz_flutter
   - ℹ️ **INFORMATIONAL**:
     - `rtk grep -rn "lastFailure|shouldReportToCrashlytics" .agents/` → zero
5. Update `.coverage_exclude` if new test utils appear; bump nothing else.

## Accepted Deviations

- `auth_endpoint.completeRegistration` signature changes to `(Session, RegistrationForm)` — requires `serverpod generate` for client. Documented as required deviation.
- **Full-fluid responsive chart heights** — deferred to separate plan requiring designer input + golden regen.
- **ErrorActions promotion to shared** — deferred; requires dep-inversion seam (DialogUtils/localization). Per-app drift is known debt: `baktaz_admin` lacks `onAuthenticationError`/`onRemoteConfigError`; validation handler differs.
