# Rules-Audit Violations Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remediate the 2026-08-26 rule audit: eliminate the Pattern-B violation in `LoginState`, localize all hardcoded user-facing strings in `baktaz_flutter`, migrate deprecated `PopupMenuButton`, introduce typed `RemoteConfigState`, and clear metric/naming/magic-number violations.

**Architecture:** Flutter monorepo (baktaz_flutter client, baktaz_admin dashboard, baktaz_shared design system, baktaz_server Serverpod backend). State = `CubitSignal<S>` (bloc_signals), repos return `TaskResult<T>` (fpdart), errors routed through sealed `Failure` → `FailureHandler.handleFailure` side-effects (Pattern B — state never stores `Failure`). Localization via slang (`assets/i18n/en.i18n.json` → `lib/app/generated/localization.g.dart`). Design tokens in `AppSizes`.

**Tech Stack:** Flutter 3.47+, Dart ≥3.13, Serverpod 2.x/4.0.0-beta.3 auth modules, bloc_signals, fpdart, freezed, injectable, slang, mockito, Alchemist goldens.

**Spec:** Audit report 2026-08-26 (session memory) + `.agents/rules/*.md`. Note: original audit findings C1/C2 (`serverpod_auth_*` imports) are VOID — rule updated same day to sanction those packages.

## Global Constraints

- Use `fvm` for all flutter/dart commands: `fvm flutter test`, `fvm dart analyze`.
- Lints: `very_good_analysis` + DCM, treat infos as fatal. Width 120 chars.
- Functions < 50 lines, files ≤ 800 lines, nesting ≤ 4 levels, ≤ 5 params.
- Codegen order ALWAYS: 1) `fvm dart run slang` 2) `fvm dart run build_runner build --delete-conflicting-outputs` 3) `serverpod generate` (only when `.spy.yaml` changed — none in this plan).
- Never edit generated files: `*.g.dart`, `*.freezed.dart`, `gen/`.
- Tests: mockito only (never mocktail); mocks registered in `baktaz_flutter/test/utils/generated_mocks.dart`; AAA naming like `emits failed state without Failure payload when repo returns left`.
- Coverage: overall ≥80%, Cubit/Repo 100%.
- No hardcoded user-facing strings outside `*_server`; use `context.i18n.*` (slang).
- Commits: conventional `<type>: <description>`; commit after every passing task.
- Worktree: execute in isolated git worktree created via superpowers:using-git-worktrees.

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

### Task 4: PopupMenuButton → MenuAnchor (admin)

**Files:**
- Modify: `baktaz_admin/lib/features/remote_config/presentation/widgets/parameter_table.dart:165-220`

**Interfaces:**
- Consumes: callback `void Function(SortCriteria)` named `onSortCriteriaSelected` (existing widget param), `sortCriteria` field, i18n keys `remote_config.table.sort_options|sort_alpha|sort_type|sort_date`.
- Produces: identical UX via Material 3 `MenuAnchor`; no public API change.

- [ ] **Step 1: Replace popup block**

Replace the whole `PopupMenuButton<SortCriteria>(...)` block (lines 165-220, ends at the closing `),` before `Gap.x2Small(),`) with:
```dart
        MenuAnchor(
          controller: menuController,
          style: const MenuStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: AppSizes.xSmall))),
          menuChildren: <Widget>[
            _SortMenuItem(
              icon: Icons.sort_by_alpha,
              label: context.i18n.remote_config.table.sort_alpha,
              selected: sortCriteria == SortCriteria.alphabetical,
              onTap: () {
                menuController.close();
                onSortCriteriaSelected(SortCriteria.alphabetical);
              },
            ),
            _SortMenuItem(
              icon: Icons.category_outlined,
              label: context.i18n.remote_config.table.sort_type,
              selected: sortCriteria == SortCriteria.type,
              onTap: () {
                menuController.close();
                onSortCriteriaSelected(SortCriteria.type);
              },
            ),
            _SortMenuItem(
              icon: Icons.date_range_outlined,
              label: context.i18n.remote_config.table.sort_date,
              selected: sortCriteria == SortCriteria.dateModified,
              onTap: () {
                menuController.close();
                onSortCriteriaSelected(SortCriteria.dateModified);
              },
            ),
          ],
          builder: (BuildContext context, MenuController controller, Widget? child) => IconButton(
            tooltip: context.i18n.remote_config.table.sort_options,
            padding: Paddings.allX2Small,
            constraints: const BoxConstraints(),
            onPressed: () => controller.open(),
            icon: BaktazIcon(
              icon: Either<String, IconData>.right(Icons.filter_list),
              size: AppSizes.iconSmall,
              color: AppColors.colorTextSecondary,
            ),
          ),
        ),
```
Obtain `menuController` in the enclosing State/Hook build: if class is HookWidget add `final MenuController menuController = useMemoized(MenuController.new);` near other hooks; if StatefulWidget add `final MenuController menuController = MenuController();` as a State field. Add imports: `package:flutter/material.dart` (present) — `MenuAnchor/MenuController/MenuItemButton/WidgetStatePropertyAll` ship in material; ensure `Paddings` imported from baktaz_shared (already used below at line 231).

Append private item widget at file bottom (before closing brace of library):
```dart
class _SortMenuItem extends StatelessWidget {
  const _SortMenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MenuItemButton(
    leadingIcon: BaktazIcon(
      icon: Either<String, IconData>.right(icon),
      size: AppSizes.iconSmall,
      color: selected ? AppColors.colorPrimary : AppColors.colorTextSecondary,
    ),
    onPressed: onTap,
    child: BaktazText(text: label),
  );
}
```
Delete the now-dead `PopupMenuItem` rows if analyzer flags anything.

- [ ] **Step 2: Analyze**

Run: `cd baktaz_admin && fvm dart analyze && fvm dart run dcm analyze 2>/dev/null || true`
(dcm via MCP preferred at review time.) Expected: no issues.

- [ ] **Step 3: Smoke via DTD (optional, server running)**

If a running app is connected: hot restart via dart MCP `hot_restart`, open Remote Config page, click filter icon — menu opens with 3 items, selection applies. If no live app, skip (analyze + suite gate suffices).

- [ ] **Step 4: Commit**

`git add -A && git commit -m "refactor(admin): migrate PopupMenuButton to Material 3 MenuAnchor"`

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

### Task 6: HomeWeeklyStepsChart → HookWidget + named chart constant

**Files:**
- Modify: `baktaz_shared/lib/src/theme/app_sizes.dart` (append token)
- Modify: `baktaz_flutter/lib/features/home/presentation/widgets/home_weekly_steps_chart.dart`
- Test: existing golden coverage for home widgets — run suite.

**Interfaces:** Produces `AppSizes.chartBarAreaHeight` (=120). Widget public API unchanged.

- [ ] **Step 1: Add token** to `app_sizes.dart` after `screenMarginH`:
```dart
  static const double chartBarAreaHeight = 120;
```

- [ ] **Step 2: Convert widget** — rewrite `home_weekly_steps_chart.dart`:
```dart
import 'package:baktaz_flutter/features/home/presentation/widgets/home_weekly_bar_item.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_weekly_chart_header.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_weekly_total_footer.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HomeWeeklyStepsChart extends HookWidget {
  const HomeWeeklyStepsChart({
    required this.weeklySteps,
    required this.averageSteps,
    required this.totalWeeklySteps,
    required this.goalTarget,
    super.key,
  });

  final List<int> weeklySteps;
  final int averageSteps;
  final int totalWeeklySteps;
  final int goalTarget;

  static const int _daysInWeek = 7;

  @override
  Widget build(BuildContext context) {
    const List<String> days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final ValueNotifier<int?> selectedIndex = useState<int?>(null);
    final List<int> safeSteps = weeklySteps.length == _daysInWeek ? weeklySteps : List<int>.filled(_daysInWeek, 0);

    return BaktazCard(
      body: Padding(
        padding: Paddings.allLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HomeWeeklyChartHeader(averageSteps: averageSteps),
            Gap.medium(),
            SizedBox(
              height: AppSizes.chartBarAreaHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List<Widget>.generate(
                  _daysInWeek,
                  (int index) => HomeWeeklyBarItem(
                    steps: safeSteps[index],
                    dayLabel: days[index],
                    goalTarget: goalTarget,
                    isSelected: selectedIndex.value == index,
                    onTap: () => selectedIndex.value = index,
                  ),
                ),
              ),
            ),
            Gap.medium(),
            HomeWeeklyTotalFooter(totalWeeklySteps: totalWeeklySteps),
          ],
        ),
      ),
    );
  }
}
```
(Also removes magic numbers 120 and 7.)

- [ ] **Step 3: Analyze + home goldens** — `cd baktaz_flutter && fvm dart analyze && fvm flutter test test/widget/features/home/ test/unit/` → green (goldens auto-refresh if pixel-shift).

- [ ] **Step 4: Commit** — `git commit -m "refactor(flutter): HomeWeeklyStepsChart to HookWidget, extract chart height token"`.

### Task 7: Server param-count fixes (RegistrationForm model + records)

**Files:**
- Create: `baktaz_server/lib/src/features/auth/domain/models/registration_form.spy.yaml`
- Modify: `baktaz_server/lib/src/features/auth/endpoint/auth_endpoint.dart` (endpoint signature + body)
- Modify: `baktaz_server/lib/src/features/auth/domain/interface/i_auth_repository.dart`
- Modify: `baktaz_server/lib/src/features/auth/data/repository/auth_repository.dart`
- Modify: `baktaz_server/lib/src/app/utils/auth_utils.dart:114-131`
- Modify: `baktaz_client/lib/src/protocol/features/auth/domain/models/registration_form.dart` (auto-generated, verify)
- NOTE: `auth_endpoint.dart` signature CHANGES — this requires `serverpod generate` to update client. Document as required deviation.

**Interfaces:**
- Produces `RegistrationForm` Serverpod model:
```yaml
# registration_form.spy.yaml
class: RegistrationForm
table: none
fields:
  email: String
  name: String
  gender: String
  registrationToken: String
  birthday: DateTime?
```
Generated class: `RegistrationForm` with fields `email`, `name`, `gender`, `registrationToken`, `birthday`.
Endpoint becomes: `Future<OtpVerificationResult> completeRegistration(Session session, RegistrationForm form) async`
Interface becomes: `Future<OtpVerificationResult> completeRegistration(Session session, RegistrationForm form);`
Repo becomes: `Future<OtpVerificationResult> completeRegistration(Session session, RegistrationForm form) async`

- [ ] **Step 1: Create RegistrationForm spy.yaml**

Create `baktaz_server/lib/src/features/auth/domain/models/registration_form.spy.yaml`:
```yaml
class: RegistrationForm
table: none
fields:
  email: String
  name: String
  gender: String
  registrationToken: String
  birthday: DateTime?
```

- [ ] **Step 2: Run serverpod generate**

Run: `cd baktaz_server && fvm dart run serverpod generate`
Expected: Generated `registration_form.dart` in `baktaz_server/lib/src/generated/protocol.dart` and `baktaz_client/lib/src/protocol/features/auth/domain/models/registration_form.dart`.

- [ ] **Step 3: Update endpoint**

Replace `auth_endpoint.dart`:
```dart
import 'package:baktaz_server/src/features/auth/data/repository/auth_repository.dart';
import 'package:baktaz_server/src/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_server/src/features/security/data/service/security_logger.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:get_it/get_it.dart';
import 'package:serverpod/serverpod.dart';

final class AuthEndpoint extends Endpoint {
  AuthEndpoint([IAuthRepository? authRepository])
    : _authRepository =
          authRepository ??
          (GetIt.I.isRegistered<IAuthRepository>()
              ? GetIt.I<IAuthRepository>()
              : AuthRepository(GetIt.I.isRegistered<SecurityLogger>() ? GetIt.I<SecurityLogger>() : SecurityLogger()));

  final IAuthRepository _authRepository;

  @override
  bool get requireLogin => false;

  Future<OtpVerificationResult> completeRegistration(
    Session session,
    RegistrationForm form,
  ) async => _authRepository.completeRegistration(session, form);
}
```

- [ ] **Step 4: Update interface + repo**

`i_auth_repository.dart`:
```dart
// ignore_for_file: one_member_abstracts

import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

abstract interface class IAuthRepository {
  Future<OtpVerificationResult> completeRegistration(
    Session session,
    RegistrationForm form,
  );
}
```

`auth_repository.dart` — change signature and destructure form at top:
```dart
  @override
  Future<OtpVerificationResult> completeRegistration(
    Session session,
    RegistrationForm form,
  ) async {
    try {
      final String normalizedEmail = form.email.trim().toLowerCase();

      final String? expectedToken = await session.caches.local.get<String>('otp:token:$normalizedEmail');
      if (expectedToken == null || expectedToken != form.registrationToken) {
        throw OtpException(message: 'Invalid or expired registration token');
      }
      await session.caches.local.invalidateKey('otp:token:$normalizedEmail');

      return await session.db.transaction((Transaction transaction) async {
        // ... rest uses form.name, form.gender, form.birthday
```

- [ ] **Step 5: Fix `_createAccount` via record** — same as before (see steps 3-4 in original plan).

- [ ] **Step 6: Regenerate client** — since endpoint signature changed, client must regenerate.
Run: `cd baktaz_client && fvm dart run serverpod generate`
Verify: `baktaz_client/lib/src/protocol/features/auth/domain/models/registration_form.dart` exists.

- [ ] **Step 7: Update flutter admin calls** — search for `completeRegistration` calls in `baktaz_flutter` and `baktaz_admin`, update to pass `RegistrationForm` object:
```dart
// Before:
await _serverpod.client.auth.completeRegistration(
  email: email,
  name: name,
  gender: gender,
  birthday: birthday,
  registrationToken: registrationToken,
);

// After:
await _serverpod.client.auth.completeRegistration(
  session,
  RegistrationForm(
    email: email,
    name: name,
    gender: gender,
    birthday: birthday,
    registrationToken: registrationToken,
  ),
);
```

- [ ] **Step 8: Verify** — `cd baktaz_server && fvm dart analyze`, `cd baktaz_flutter && fvm dart analyze`, `cd baktaz_admin && fvm dart analyze`. Integration tests if Postgres up.

- [ ] **Step 9: Commit** — `git commit -m "refactor(server): promote RegistrationForm to Serverpod model, fix param counts"`.
---

### Task 8: BaktazTextField complexity (merge duplicate branches)

**Files:**
- Modify: `baktaz_shared/lib/src/widgets/baktaz_text_field.dart:116-215`

**Interfaces:** Public API untouched. Behavior preserved: `form`→TextFormField w/ validator; `email`/`normal`→TextField differing only in forced `TextInputType.emailAddress` for email.

- [ ] **Step 1: Merge email/normal switch arms** — replace the three `TextField`-producing arms with two:
```dart
        child: switch (textFieldType) {
          TextFieldType.password => _PasswordTextField(
            controller: controller,
            onChanged: onChanged,
            autofocus: autofocus,
            onSubmitted: onSubmitted,
            textInputAction: textInputAction,
            focusNode: effectiveFocusNode,
            hintText: hintText,
            labelText: labelText,
            inputDecoration: _getInputDecoration(context, style, isFocused: isFocused),
          ),
          TextFieldType.form => TextFormField(
            key: formFieldKey,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUnfocus,
            inputFormatters: inputFormatters,
            readOnly: readOnly || isDisabled,
            canRequestFocus: !(readOnly || isDisabled),
            controller: controller,
            focusNode: effectiveFocusNode,
            decoration: decoration ?? _getInputDecoration(context, style, isFocused: isFocused),
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: style,
            textAlign: textAlign,
            autofocus: autofocus,
            maxLength: maxLength,
            minLines: minLines,
            maxLines: maxLines,
            onChanged: onChanged,
            buildCounter: (_, {int? currentLength, int? maxLength, bool? isFocused}) => null,
          ),
          _ => TextField(
            key: formFieldKey,
            readOnly: readOnly || isDisabled,
            controller: controller,
            focusNode: effectiveFocusNode,
            decoration: decoration ?? _getInputDecoration(context, style, isFocused: isFocused),
            keyboardType: textFieldType == TextFieldType.email ? TextInputType.emailAddress : keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            canRequestFocus: !(readOnly || isDisabled),
            style: style,
            textAlign: textAlign,
            autofocus: autofocus,
            maxLength: maxLength,
            minLines: minLines,
            maxLines: maxLines,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            buildCounter: (_, {int? currentLength, int? maxLength, bool? isFocused}) => null,
          ),
        },
```
Complexity drops 21 → ~17 (one fewer case arm + ternary).

- [ ] **Step 2: Verify** — `cd baktaz_shared && fvm dart analyze` clean; `cd baktaz_flutter && fvm flutter test` green (text-field goldens included); `cd baktaz_admin && fvm flutter test` green.

- [ ] **Step 3: Commit** — `git commit -m "refactor(shared): collapse BaktazTextField duplicate TextField branches"`.


### Task 10: Admin magic numbers → named constants

**Files:**
**Files:**
- Modify: `baktaz_shared/lib/src/theme/app_sizes.dart` (append 4 tokens)
- Modify: `baktaz_admin/lib/features/dashboard/presentation/widgets/activities_overview_chart.dart:125`
- Modify: `baktaz_admin/lib/features/dashboard/presentation/widgets/activities_reports_chart.dart:71`
- Modify: `baktaz_admin/lib/features/content/presentation/widgets/content_table_header.dart:75`
- Modify: `baktaz_admin/lib/features/localization/presentation/widgets/dialogs/edit_translation_dialog.dart:46`
- Modify: `baktaz_admin/lib/features/localization/presentation/widgets/dialogs/add_translation_dialog.dart:26`
- Modify: `baktaz_admin/lib/features/remote_config/presentation/views/remote_config_screen.dart:307-317,433-439,477-483`

**Interfaces:** Produces `AppSizes.dialogWidth = 400`, `AppSizes.chartHeightLarge = 250`, `AppSizes.chartHeightMedium = 200`, `AppSizes.tableSearchWidth = 240`.
- [ ] **Step 1: Tokens** — append to `app_sizes.dart` after avatar block:
```dart
  // Component dimensions — DESIGN.md §component-sizes

  static const double chartHeightLarge = 250;
  static const double chartHeightMedium = 200;
  static const double tableSearchWidth = 240;
```

- [ ] **Step 2: Swap existing AppSizes** — each listed site:
  - `height: 250` → `height: AppSizes.chartHeightLarge`
  - `height: 200` → `AppSizes.chartHeightMedium`
  - `width: 400` → `AppSizes.dialogWidth` (both dialogs)
  - `width: 240` → `AppSizes.tableSearchWidth`
  - Ensure `baktaz_shared` import present.

- [ ] **Step 3: Shimmer skeletons** — `remote_config_screen.dart` lines 307-317, 433-439, 477-483. Replace:
  - `height: 16` → `AppSizes.medium`
  - `height: 12` → `AppSizes.small`
  - `width: 150` → file-local `static const double _shimmerTitleWidth = 150;`
  - `width: 120` → file-local `static const double _shimmerChipWidth = 120;`
  - `height: 14` → file-local `static const double _shimmerBarHeight = 14;`
  (No close AppSizes tokens exist for 14/120/150; use file-local for these.)

- [ ] **Step 4: Verify** — `cd baktaz_admin && fvm dart analyze && fvm flutter test` → green.

- [ ] **Step 5: Commit** — `git commit -m "fix(admin): extract magic dimensions into named constants"`.
and swap lines 307 (`width: _shimmerTitleWidth`), 433 & 477 (`width: _shimmerChipWidth`), plus their paired `height: 16`→`_shimmerBarHeight`.

- [ ] **Step 3: Verify** — `cd baktaz_admin && fvm dart analyze && fvm flutter test` → green.

- [ ] **Step 4: Commit** — `git commit -m "fix(admin): extract magic dimensions into named constants"`.

## Final Verification (all tasks done)

1. Monorepo analyze: `melos exec -- fvm dart analyze` OR per-package loop.
2. Suites: `make test_flutter`, `make test_admin`; `make test_server` only if Postgres up.
3. DCM re-audit: confirm cyclomatic-complexity >20 and number-of-parameters >5 lists are empty.
4. Grep gates:
   - `rtk grep -rn "\"[A-Z][a-z].*\"" baktaz_flutter/lib/features baktaz_flutter/lib/core/presentation` → zero UI-literal hits.
   - `rtk grep -rn "PopupMenuButton" baktaz_admin/lib` → zero.
   - `rtk grep -rn "CubitSignal<Map" baktaz_flutter/lib` → zero.
5. Update `.coverage_exclude` if new test utils appear; bump nothing else.

## Accepted Deviations (documented non-fixes)

- `auth_endpoint.completeRegistration` signature changes to `(Session, RegistrationForm)` — requires `serverpod generate` for client. Documented as required deviation.
- `connectivity_checker` instance-constructor (child/offlineMessage/2 callbacks) stays 4-param compliant; only static `scaffold` slimmed.
- Serverpod `return null` endpoints (NP1/NP2) — legitimate business absence per error-handling rules.
