# Master Integration Plan — Monorepo Feature Slices

**Date:** 2026-08-30  
**Status:** Finalized & Approved / Active Execution Roadmap  
**Target:** Monorepo (`baktaz_server`, `baktaz_flutter`, `baktaz_admin`, `baktaz_shared`, `baktaz_client`)

---

## 1. Executive Summary

This Master Integration Plan synthesizes and sequences all 10 feature plan suites across the Baktaz monorepo into an aligned, dependency-safe execution sequence. It resolves structural overlaps, prevents circular package dependencies, enforces clean architectural seams, and maximizes build efficiency.

### Unified Plan Suites Integrated
1. **Remote Config** (`docs/superpowers/plans/remote_config/`)
2. **Remote Localization** (`docs/superpowers/plans/remote_localization/2026-08-30-remote-localization.md`)
3. **Account** (`docs/superpowers/plans/account/`)
4. **Profile** (`docs/superpowers/plans/profile/`)
5. **Steps** (`docs/superpowers/plans/steps/`)
6. **Challenge** (`docs/superpowers/plans/challenge/`)
7. **Payment** (`docs/superpowers/plans/payment/`)
8. **Chat** (`docs/superpowers/plans/chat/`)
9. **Manage Payment & Payout Destinations** (`docs/superpowers/plans/manage_payment/`)
10. **Subscription** (`docs/superpowers/plans/subscription/`)

### Established Foundation Document
- **Home Screen UI** (`docs/superpowers/archive/done-2026-08-22-home-screen-ui.md`): Established foundation document for the `/home` dashboard UI, `HomePage`, `DailyStepHeroCard`, `WeeklyStepsChart`, `ActiveChallengeTicker`, and `LeaderboardPreview` widgets.

---

## 2. Global Execution Rules & Invariants

### 1. Vertical Slice Isolation & Codegen Efficiency
Each feature slice is built completely end-to-end (Server Models → Server Endpoints → Client SDK → Flutter Core & UI) before moving to the next feature slice.
- Run `serverpod generate` and `serverpod create-migration` once per completed feature slice to keep migrations clean and minimize code generation overhead.

### 2. Interface Seams & Stubbing Strategy
To enable end-to-end execution and testing of early features before their backend dependencies exist (e.g. Challenge requiring payment entry tickets before Payment gateway integration), define explicit interfaces in domain contracts:
- `IPaymentRepository`: Concrete implementation provided in Feature 4 (Payment). Interface declared in Feature 3 (Challenge).
- `IHostSubscriptionRepository`: Concrete implementation provided in Feature 7 (Subscription). Interface declared in Feature 3 (Challenge).

### 3. Canonical Architecture Paths
Per monorepo `flutter-architecture.md` and `serverpod-architecture.md`:
- Server models: `baktaz_server/lib/src/features/<feature>/domain/model/<name>.spy.yaml`
- Server interfaces: `baktaz_server/lib/src/features/<feature>/domain/interface/i_<name>_repository.dart`
- Server repositories: `baktaz_server/lib/src/features/<feature>/data/repository/<name>_repository.dart`
- Server endpoints: `baktaz_server/lib/src/features/<feature>/endpoint/<name>_endpoint.dart`
- Flutter interfaces: `baktaz_flutter/lib/features/<feature>/domain/interface/i_<name>_repository.dart`
- Flutter repositories: `baktaz_flutter/lib/features/<feature>/data/repository/<name>_repository.dart`
- Flutter cubits: `baktaz_flutter/lib/features/<feature>/presentation/cubit/<name>_cubit.dart`
- Flutter views: `baktaz_flutter/lib/features/<feature>/presentation/views/<name>_screen.dart` (or `_page.dart`)

### 4. Implementation-First Testing Invariants
Per monorepo `.agents/rules/testing.md` guidelines, testing strictly follows 100% completion of implementation and codegen for that vertical slice:
- [ ] **1. Implementation-First Order**: Zero unit, widget, or integration tests written or executed until non-test code, model generation (`.spy.yaml`), slang localization, and client SDK regeneration are 100% complete across all packages for that feature slice.
- [ ] **2. Flutter Canonical Test Paths & Coverage Targets**:
  - Unit tests: Flat structure in `baktaz_flutter/test/unit/<feature>_<type>_test.dart` (100% coverage target for Repositories and Cubits).
  - Widget tests: In `baktaz_flutter/test/widget/<feature>/<widget_name>_test.dart` (goldens via `alchemist` with 15% tolerance in `goldens/` subfolder; ≥80% coverage target).
  - Forbidden: Full-screen widget tests, screen tests (only test widgets), interface tests, `mocktail` (use `mockito` with `baktaz_flutter/test/utils/generated_mocks.dart` and `flutter_test_config.dart`).
- [ ] **3. Server Canonical Test Paths**:
  - Repository unit tests: In `baktaz_server/test/unit/<feature>/<repository>_test.dart`.
  - Endpoint integration tests: In `baktaz_server/test/integration/<feature>/<endpoint>_test.dart` using `withServerpod`.
- [ ] **4. Package Coverage Exclusions (`.coverage_exclude`)**:
  - **`baktaz_flutter/.coverage_exclude`**: `lib/app/*`, `lib/main.dart`, `*.g.dart`, `*.freezed.dart`, `*.dto.dart`, `*.config.dart`, `*.chopper.dart`, `*_screen.dart`, `*_webview.dart`, `**/wrappers/*.dart`, `*_state.dart`, `**/pages/*`, `**/service/*`, `**/entity/*`, `**/dto/*`, `**/views/*`.
  - **`baktaz_server/.coverage_exclude`**: `**/app/*`, `**/generated/*`, `**/domain/**`, `**/*.chopper.dart`.
  - **`baktaz_shared/.coverage_exclude`**: `*.g.dart`, `*.freezed.dart`, `*.dto.dart`, `*.config.dart`, `*.chopper.dart`, `*_state.dart`, `**/theme/*.dart`, `**/entity/*.dart`, `**/dto/*.dart`, `**/converters/*.dart`, `**/extensions/*.dart`, `*/formatters/*.dart`, `*/utils/*.dart`, `*/widgets/wrappers/*.dart`, `*/domain/*.dart`, `*/mixin/*.dart`, `*/observer/*.dart`.
  - **`baktaz_admin/.coverage_exclude`**: `lib/app/*`, `lib/main.dart`, `*.g.dart`, `*.freezed.dart`, `*.dto.dart`, `*.config.dart`, `*.chopper.dart`, `*_screen.dart`, `*_webview.dart`, `**/wrappers/*.dart`, `*_state.dart`, `**/pages/*`, `**/service/*`, `**/entity/*`, `**/dto/*`.
  - **Coverage Scoping Note**: Test coverage targets (100% Repositories and Cubits, ≥80% overall) apply strictly to non-excluded files.

### 5. CubitSignal & Pattern B Side-Effect Error Handling Invariants
Per monorepo `.agents/rules/flutter-architecture.md`, `state-management-architecture.md`, and `error-handling-architecture.md`:
- All Flutter state controllers MUST extend `CubitSignal<S>` with an `initialState:` named constructor (`.agents/rules/flutter-architecture.md`, `state-management-architecture.md`).
- Error handling MUST follow Pattern B: states hold continuous values; transient side-effects (toasts/snackbars) are emitted via presentation streams using `safeRun(onException:)` (`.agents/rules/error-handling-architecture.md`).
- All Flutter repositories MUST return `TaskResult<T>` (`Either<Failure, T>`), never throwing exceptions (`.agents/rules/flutter-architecture.md`).

### 6. Typed Navigation & UI Design System Invariants
- All Flutter navigation MUST use `go_router_builder` `@TypedGoRoute` or `@TypedShellRoute` classes registered in `baktaz_flutter/lib/app/routes/app_routes.dart`.
- All UI widgets/views MUST exclusively use `baktaz_shared` UI components (`BaktazText`, `BaktazButton`, `BaktazCard`, `BaktazTextField`, `BaktazAvatar`, `BaktazStatusBadge`, `BaktazSectionHeader`, `ConfirmationDialog`, `StageProgressBar`, `SlotsProgressRing`, `FireIcon`, `LeadersStrip`, `RankTrend`, `GapMeter`, `WeeklyStepsBarChart`, `LeaderboardTable`, `BaktazFAB`, `NotificationIconButton`, `StatSubCard`, `RankBadge`, `AvatarStack`, `StakeReturnValue`, `IdentityBlock`), M3 `ColorScheme` roles (`scheme.primary` `#10B981`/`#34D399`, `scheme.surface`, `scheme.primaryContainer`, `scheme.inverseSurface`, `scheme.tertiary`), `Theme.of(context).textTheme.*` for standard text styles (reserving `BaktazType` strictly for display styles: `displayHero`, `metricHero`, `headlineTitle`, `subheadingUppercase`, `labelRanking`), `BaktazSpacing.*` and `BaktazRadius.*` tokens, and `context.i18n.<feature>.<key>` (snake_case) Slang localization. `baktaz_shared` widgets MUST receive localized `String` parameters/props from caller screens and NOT access `context.i18n` directly.

### 7. Defensive Architecture & Anti-Bug Invariants
- [ ] **Step Ingestion & Anti-Cheat Invariants**
  - [ ] Monotonic `max(existingSteps, newSteps)` DB writes to prevent step regression.
  - [ ] Rejection of manual step inputs (`HKWasUserEntered` / `WAS_MANUALLY_ENTERED`).
  - [ ] 30,000 daily step ceiling threshold (`AppConfig.maxDailyStepCeiling = 30000`), flagging steps > 30k as `onHold` for review before escrow payout.
  - [ ] 24-hour validation window after challenge completion before payout disbursement.
- [ ] **Financial Webhook & Ledger Idempotency Invariants**
  - [ ] Webhook idempotency verification via `gatewayTransactionId` to reject duplicate callbacks.
  - [ ] Double-entry ledger debit/credit balance verification.
- [ ] **Resource & Lifecycle Safety Invariants**
  - [ ] Explicit cancellation of WebSocket stream subscriptions in `ChatCubit.close()`.
  - [ ] Client-side image compression (max 2MB, max 5 photo attachments per message).
  - [ ] Fail-safe silent fallback for background OTA localization fetch errors to `en.i18n.json`.

### 8. Server-Side Security, Boundary Input Validation & Idempotency Invariants
- [ ] **Authentication & Identity Derivation**
  - [ ] All authenticated endpoints MUST enforce `requireLogin = true` and derive user identity exclusively from `session.auth.authenticatedUserId`.
  - [ ] Client-supplied `userId` parameters in RPC method calls are strictly forbidden.
- [ ] **Boundary Input Validation**
  - [ ] Endpoints validate all inputs at boundary RPC layer (e.g., step range 0–100,000, positive amounts > 0, non-empty strings) before calling repository methods.
  - [ ] Throws typed `ApiException` or `.spy.yaml` exceptions logged via `session.log()`.
- [ ] **Server-Side Idempotency**
  - [ ] **Step Sync**: Monotonic `max(existing, new)` DB upserts on `DailyStepTelemetry`.
  - [ ] **Webhooks**: Idempotent callback processing using `gatewayTransactionId` to prevent duplicate transaction credits.
  - [ ] **Challenge Join**: Idempotent join handling using `(challengeId, userId)` unique index.
  - [ ] **Subscription**: Transactional status checks preventing double-activations.

### 9. Phase Review Gates & User Verification Invariants
- [ ] **Mandatory Phase Gate**: After completing all implementation, codegen, DB migrations, and tests for a feature slice (Step 0 through Feature 7), execution MUST pause.
- [ ] **Review Output**: Agent presents:
  - [ ] Summary of completed work and test pass status.
  - [ ] Staged files list via `git add`.
- [ ] **Explicit User Approval Gate**: Agent MUST wait for user confirmation before starting the next feature slice.
- [ ] **No Automatic Commits**: ZERO automatic `git commit` commands. All changes stay staged until user explicitly says "commit".

### 10. Out-of-Scope Items & Canonical `TODO` Markers
- [ ] **Secrets & Credentials**
  - [ ] HitPay API secret keys, S3 presigned upload credentials, and OAuth client IDs loaded strictly from environment configuration (`config/passwords.yaml` / `envied`).
  - [ ] Deferred hardcoding credentials in source.
  - [ ] Marker: `// TODO(config): load production credentials from environment / passwords.yaml`
- [ ] **`baktaz_admin` Web Dashboard UI**
  - [ ] Admin management screens for remote config keys, localization releases, event templates, and manual anti-cheat flag reviews (`onHold` participant overrides) deferred to `baktaz_admin`.
  - [ ] Marker: `// TODO(admin): build baktaz_admin management screen for <feature>`
- [ ] **Secondary Health Integrations**
  - [ ] Strava API and Samsung Health direct sync deferred for post-MVP.
  - [ ] Marker: `// TODO(health): integrate Strava API / Samsung Health providers`

---

## 3. Execution Sequence (Vertical Feature Slices)

```
[Step 0: Infrastructure Foundation] ──► [Feature 1: Account + Profile] ──► [Feature 2: Steps]
                                                                                │
[Feature 5: Chat] ◄── [Feature 4: Payment] ◄── [Feature 3: Challenge (Stubs)] ◄─┘
       │
       ▼
[Feature 6: Manage Payment & Payout Destinations] ──► [Feature 7: Subscription]
```

---

### Step 0: Remote Config & Remote Localization (Infrastructure Foundation)

**Goal:** Establish dynamic app configuration and over-the-air (OTA) localization capabilities before higher-level features require dynamic content or keys.

- [ ] **0.1 Remote Config Serverpod Models (`baktaz_server`)**
  - [ ] Create `baktaz_server/lib/src/features/remote_config/domain/model/remote_config_value_type.spy.yaml` (`RemoteConfigValueType` enum).
  - [ ] Create `baktaz_server/lib/src/features/remote_config/domain/model/config_key.spy.yaml` (`ConfigKey` table model).
  - [ ] Create `baktaz_server/lib/src/features/remote_config/domain/model/targeting_override.spy.yaml` (`TargetingOverride` table model).
  - [ ] Create `baktaz_server/lib/src/features/remote_config/domain/model/config_snapshot_version.spy.yaml` (`ConfigSnapshotVersion` table model).
  - [ ] Create `baktaz_server/lib/src/features/remote_config/domain/model/public_config_version.spy.yaml` (`PublicConfigVersion` DTO).
  - [ ] Create `baktaz_server/lib/src/features/remote_config/domain/model/remote_config_default_value.spy.yaml` (`RemoteConfigDefaultValue` DTO).
  - [ ] Create `baktaz_server/lib/src/features/remote_config/domain/model/remote_config_value.spy.yaml` (`RemoteConfigValue` DTO).
  - [ ] Create `baktaz_server/lib/src/features/remote_config/domain/model/remote_config.spy.yaml` (`RemoteConfig` DTO).
- [ ] **0.2 Remote Localization Serverpod Models (`baktaz_server`)**
  - [ ] Create `baktaz_server/lib/src/features/remote_localization/domain/model/remote_localization_release.spy.yaml` (`RemoteLocalizationRelease` table model).
  - [ ] Create `baktaz_server/lib/src/features/remote_localization/domain/model/remote_localization_audit_log.spy.yaml` (`RemoteLocalizationAuditLog` table model).
  - [ ] Create `baktaz_server/lib/src/features/remote_localization/domain/model/remote_localization_response.spy.yaml` (`RemoteLocalizationResponse` DTO).
- [ ] **0.3 Server Repositories & Endpoints (`baktaz_server`)**
  - [ ] Implement `IRemoteConfigRepository` in `baktaz_server/lib/src/features/remote_config/domain/interface/i_remote_config_repository.dart`.
  - [ ] Implement `RemoteConfigRepository` in `baktaz_server/lib/src/features/remote_config/data/repository/remote_config_repository.dart`.
  - [ ] Expose `RemoteConfigEndpoint` in `baktaz_server/lib/src/features/remote_config/endpoint/remote_config_endpoint.dart`.
  - [ ] Implement `IRemoteLocalizationRepository` in `baktaz_server/lib/src/features/remote_localization/domain/interface/i_remote_localization_repository.dart`.
  - [ ] Implement `RemoteLocalizationRepository` in `baktaz_server/lib/src/features/remote_localization/data/repository/remote_localization_repository.dart`.
  - [ ] Expose `RemoteLocalizationEndpoint` in `baktaz_server/lib/src/features/remote_localization/endpoint/remote_localization_endpoint.dart`.
- [ ] **0.4 Seeding Infrastructure (`baktaz_server`)**
  - [ ] Implement `seedRemoteConfig` and `seedRemoteLocalization` in `baktaz_server/lib/src/app/utils/seeding_utils.dart`.
  - [ ] Wire initial remote config and localization seeding calls into `bin/seed.dart` CLI script and `server.dart` startup initialization.
- [ ] **0.5 Flutter Services & Local Caching (`baktaz_flutter`)**
  - [ ] Implement `ServerpodRemoteConfigService` in `baktaz_flutter/lib/core/data/service/serverpod_remote_config_service.dart`.
  - [ ] Implement `RemoteLocalizationRepository` in `baktaz_flutter/lib/core/data/repository/remote_localization_repository.dart` for background OTA sync and local cache fallback.
- [ ] **0.6 Codegen & Verification**
  - [ ] Execute `serverpod generate && serverpod create-migration`.
  - [ ] Apply migration locally and run endpoint integration tests (`baktaz_server/test/integration/remote_config/remote_config_endpoint_test.dart`, `baktaz_server/test/integration/remote_localization/remote_localization_endpoint_test.dart`) using `withServerpod`.
  - [ ] Run repository unit tests (`baktaz_server/test/unit/remote_config/remote_config_repository_test.dart`, `baktaz_server/test/unit/remote_localization/remote_localization_repository_test.dart`) and Flutter unit tests (`baktaz_flutter/test/unit/remote_localization_repository_test.dart`).

---

### Feature 1: Account + Profile (User Identity & State Consolidation)

**Goal:** Consolidate identity models (`UserInfo` with `firstName`, `lastName`, and unique `username` index) and user state (`AccountSummary` with `isPremium` flag) into a single cohesive foundation.

- [ ] **1.1 Serverpod Models & DB Schema (`baktaz_server`)**
  - [ ] Update `UserInfo` model (`baktaz_server/lib/src/features/account/domain/model/user_info.spy.yaml`) with `firstName`, `lastName`, and unique `username` index.
  - [ ] Create `AccountSummary` model (`baktaz_server/lib/src/features/account/domain/model/account_summary.spy.yaml`) containing `userId`, `isPremium`, `totalSteps`, and `activeChallengeCount`.
- [ ] **1.2 Username Auto-Derivation & Seeding Utilities (`baktaz_server`)**
  - [ ] Implement `UsernameUtils` in `baktaz_server/lib/src/app/utils/username_utils.dart` for auto-generating unique handles from name or email.
  - [ ] Update `AuthRepository.completeRegistration` in `baktaz_server` to perform handle auto-derivation via `UsernameUtils` when registration handle is omitted.
  - [ ] Add `seedAdminUser` in `baktaz_server/lib/src/app/utils/seeding_utils.dart` (called in `bin/seed.dart` and `server.dart`).
- [ ] **1.3 Backend Repositories & Endpoints (`baktaz_server`)**
  - [ ] Implement `IAccountRepository` in `baktaz_server/lib/src/features/account/domain/interface/i_account_repository.dart`.
  - [ ] Implement `AccountRepository` in `baktaz_server/lib/src/features/account/data/repository/account_repository.dart`.
  - [ ] Expose `AccountEndpoint` in `baktaz_server/lib/src/features/account/endpoint/account_endpoint.dart` (`getSummary`, `updateProfile`, `checkUsernameAvailability`).
  - [ ] Implement `IProfileRepository` in `baktaz_server/lib/src/features/profile/domain/interface/i_profile_repository.dart`.
  - [ ] Implement `ProfileRepository` in `baktaz_server/lib/src/features/profile/data/repository/profile_repository.dart`.
  - [ ] Expose `ProfileEndpoint` in `baktaz_server/lib/src/features/profile/endpoint/profile_endpoint.dart`.
- [ ] **1.4 Flutter Client Implementation (`baktaz_flutter`)**
  - [ ] Implement `IAccountRepository` in `baktaz_flutter/lib/features/account/domain/interface/i_account_repository.dart`.
  - [ ] Implement `AccountRepository` in `baktaz_flutter/lib/features/account/data/repository/account_repository.dart`.
  - [ ] Create `AccountCubit` in `baktaz_flutter/lib/features/account/presentation/cubit/account_cubit.dart`.
  - [ ] Build `AccountPage` in `baktaz_flutter/lib/features/account/presentation/views/account_page.dart` using `baktaz_shared` wrappers and `context.i18n.account.*` keys.
  - [ ] Implement `IProfileRepository` in `baktaz_flutter/lib/features/profile/domain/interface/i_profile_repository.dart`.
  - [ ] Implement `ProfileRepository` in `baktaz_flutter/lib/features/profile/data/repository/profile_repository.dart`.
  - [ ] Create `ProfileCubit` in `baktaz_flutter/lib/features/profile/presentation/cubit/profile_cubit.dart`.
  - [ ] Build `ProfileEditScreen` in `baktaz_flutter/lib/features/profile/presentation/views/profile_edit_screen.dart` using `baktaz_shared` wrappers and `context.i18n.profile.*` keys.
  - [ ] Register typed routes `@TypedGoRoute<AccountRoute>(path: '/account')` for `AccountPage` and `@TypedGoRoute<ProfileRoute>(path: '/account/profile')` for `ProfileEditScreen` in `baktaz_flutter/lib/app/routes/app_routes.dart`.
- [ ] **1.5 Codegen & Testing**
  - [ ] Run `serverpod generate && serverpod create-migration`.
  - [ ] Execute Serverpod repository unit tests (`baktaz_server/test/unit/account/account_repository_test.dart`, `baktaz_server/test/unit/profile/profile_repository_test.dart`) and endpoint integration tests (`baktaz_server/test/integration/account/account_endpoint_test.dart`, `baktaz_server/test/integration/profile/profile_endpoint_test.dart`) using `withServerpod`.
  - [ ] Execute Flutter unit tests (`baktaz_flutter/test/unit/account_repository_test.dart`, `baktaz_flutter/test/unit/account_cubit_test.dart`, `baktaz_flutter/test/unit/profile_repository_test.dart`, `baktaz_flutter/test/unit/profile_cubit_test.dart`) and widget tests in `baktaz_flutter/test/widget/account/` and `baktaz_flutter/test/widget/profile/`.

---

### Feature 2: Steps (Step Telemetry & Analytics)

**Goal:** Implement step collection, ingestion, aggregation, health device integration, and analytics reporting, connecting directly into completed Home Screen UI widgets (`DailyStepHeroCard` step count and sync footer, `WeeklyStepsChart` telemetry display).

- [ ] **2.1 Serverpod Step Models & Migration (`baktaz_server`)**
  - [ ] Define `UserDevice` in `baktaz_server/lib/src/features/steps/domain/model/user_device.spy.yaml`.
  - [ ] Define `HealthIntegration` in `baktaz_server/lib/src/features/steps/domain/model/health_integration.spy.yaml`.
  - [ ] Define `StepSync` in `baktaz_server/lib/src/features/steps/domain/model/step_sync.spy.yaml`.
  - [ ] Define `DailyStepTelemetry` in `baktaz_server/lib/src/features/steps/domain/model/daily_step_telemetry.spy.yaml`.
- [ ] **2.2 Ingestion & Aggregation Service (`baktaz_server`)**
  - [ ] Implement `IStepRepository` in `baktaz_server/lib/src/features/steps/domain/interface/i_step_repository.dart`.
  - [ ] Implement `StepRepository` in `baktaz_server/lib/src/features/steps/data/repository/step_repository.dart` for batch step sync processing and daily telemetry aggregations.
  - [ ] Expose `StepEndpoint` in `baktaz_server/lib/src/features/steps/endpoint/step_endpoint.dart` with batch upload and date-range telemetry query support.
- [ ] **2.3 Flutter Step Tracking Integration (`baktaz_flutter`)**
  - [ ] Build step telemetry background service / health kit sync wrapper in `baktaz_flutter/lib/features/steps/data/service/step_telemetry_service.dart`.
  - [ ] Implement `IStepRepository` in `baktaz_flutter/lib/features/steps/domain/interface/i_step_repository.dart`.
  - [ ] Implement `StepRepository` in `baktaz_flutter/lib/features/steps/data/repository/step_repository.dart`.
  - [ ] Connect steps telemetry and health sync directly into completed Home Screen UI widgets (`DailyStepHeroCard` step count and sync footer, `WeeklyStepsChart` telemetry display).
  - [ ] Create `StepAnalyticsCubit` in `baktaz_flutter/lib/features/steps/presentation/cubit/step_analytics_cubit.dart`.
  - [ ] Build `StepAnalyticsPage` in `baktaz_flutter/lib/features/steps/presentation/views/step_analytics_page.dart` using `baktaz_shared` wrappers and `context.i18n.steps.*` keys.
  - [ ] Register typed route `@TypedGoRoute<StepAnalyticsRoute>(path: '/account/steps')` for `StepAnalyticsPage` in `baktaz_flutter/lib/app/routes/app_routes.dart`.
- [ ] **2.4 Codegen & Testing**
  - [ ] Run `serverpod generate && serverpod create-migration`.
  - [ ] Execute Serverpod repository unit tests (`baktaz_server/test/unit/steps/step_repository_test.dart`) and endpoint integration tests (`baktaz_server/test/integration/steps/step_endpoint_test.dart`) using `withServerpod`.
  - [ ] Execute Flutter unit tests (`baktaz_flutter/test/unit/step_repository_test.dart`, `baktaz_flutter/test/unit/step_analytics_cubit_test.dart`) and widget tests in `baktaz_flutter/test/widget/steps/`.

---

### Feature 3: Challenge (Creation, Discovery, Leaderboards & Shared Interface Seams)

**Goal:** Deliver end-to-end challenge lifecycle management, declaring shared interface contracts for payment entry fees and host subscriptions so Challenge compiles cleanly. `ChallengePage` and discovery feed link into the Home Screen's `ActiveChallengeTicker` and `LeaderboardPreview` widgets (`HomePage` `goBranch(1)` navigation).

- [ ] **3.1 Declare Shared Interface Seams & Stubs (`baktaz_flutter`)**
  - [ ] Create `IPaymentRepository` (`processEntryFee`, `refundEntryFee`) interface in `baktaz_flutter/lib/features/payment/domain/interface/i_payment_repository.dart`.
  - [ ] Create `IHostSubscriptionRepository` (`verifyHostTier`, `canHostChallenge`) interface in `baktaz_flutter/lib/features/account/domain/interface/i_host_subscription_repository.dart` (or `baktaz_flutter/lib/features/subscription/domain/interface/i_host_subscription_repository.dart`).
  - [ ] Create `StubPaymentRepository` in `baktaz_flutter/lib/features/payment/data/repository/stub_payment_repository.dart`.
  - [ ] Create `StubHostSubscriptionRepository` in `baktaz_flutter/lib/features/subscription/data/repository/stub_host_subscription_repository.dart`.
- [ ] **3.2 Serverpod Challenge Models & Schema (`baktaz_server`)**
  - [ ] Define `ChallengeConfig` in `baktaz_server/lib/src/features/challenge/domain/model/challenge_config.spy.yaml`.
  - [ ] Define `Challenge` in `baktaz_server/lib/src/features/challenge/domain/model/challenge.spy.yaml`.
  - [ ] Define `ChallengeParticipant` in `baktaz_server/lib/src/features/challenge/domain/model/challenge_participant.spy.yaml`.
  - [ ] Define `ChallengeLeaderboard` in `baktaz_server/lib/src/features/challenge/domain/model/challenge_leaderboard.spy.yaml` as a **transient DTO** (without `table:` directive), computed on-the-fly from `ChallengeParticipant` step totals and cached in `session.caches.local` to optimize DB performance and eliminate table redundancy.
- [ ] **3.3 Endpoints, Business Logic & Scheduled Jobs (`baktaz_server`)**
  - [ ] Implement `IChallengeRepository` in `baktaz_server/lib/src/features/challenge/domain/interface/i_challenge_repository.dart`.
  - [ ] Implement `ChallengeRepository` in `baktaz_server/lib/src/features/challenge/data/repository/challenge_repository.dart`.
  - [ ] Expose `ChallengeEndpoint` in `baktaz_server/lib/src/features/challenge/endpoint/challenge_endpoint.dart` (`createChallenge`, `joinChallenge`, `getDiscoveryFeed`, `getLeaderboard`, `getChallengeConfig`).
  - [ ] Implement Serverpod `FutureCall` scheduled lifecycle jobs (`ChallengePhaseTransitionJob`, `ChallengePayoutCalculationJob`) in `baktaz_server/lib/src/features/challenge/job/` for automated phase transitions and payout calculation.
- [ ] **3.4 Flutter Presentation & State (`baktaz_flutter`)**
  - [ ] Implement `IChallengeRepository` in `baktaz_flutter/lib/features/challenge/domain/interface/i_challenge_repository.dart`.
  - [ ] Implement `ChallengeRepository` in `baktaz_flutter/lib/features/challenge/data/repository/challenge_repository.dart`.
  - [ ] Link `ChallengePage` and discovery feed into the Home Screen's `ActiveChallengeTicker` and `LeaderboardPreview` widgets (`HomePage` `goBranch(1)` navigation).
  - [ ] Create `ChallengeDiscoveryCubit` in `baktaz_flutter/lib/features/challenge/presentation/cubit/challenge_discovery_cubit.dart`.
  - [ ] Create `ChallengeDetailCubit` in `baktaz_flutter/lib/features/challenge/presentation/cubit/challenge_detail_cubit.dart`.
  - [ ] Create `ChallengeCreateCubit` in `baktaz_flutter/lib/features/challenge/presentation/cubit/challenge_create_cubit.dart`.
  - [ ] Build `ChallengePage` in `baktaz_flutter/lib/features/challenge/presentation/views/challenge_page.dart` (bottom nav tab) using `baktaz_shared` wrappers and `context.i18n.challenge.*` keys.
  - [ ] Build `ChallengeCreateScreen` in `baktaz_flutter/lib/features/challenge/presentation/views/challenge_create_screen.dart` using `baktaz_shared` wrappers and `context.i18n.challenge.*` keys.
  - [ ] Build `ChallengeLeaderboardPage` in `baktaz_flutter/lib/features/challenge/presentation/views/challenge_leaderboard_page.dart` using `baktaz_shared` wrappers and `context.i18n.challenge.*` keys.
  - [ ] Register typed routes `@TypedGoRoute<ChallengeRoute>(path: '/challenge')` for `ChallengePage`, `@TypedGoRoute<ChallengeCreateRoute>(path: '/challenge/create')` for `ChallengeCreateScreen`, and `@TypedGoRoute<ChallengeLeaderboardRoute>(path: '/challenge/:id/leaderboard')` for `ChallengeLeaderboardPage` in `baktaz_flutter/lib/app/routes/app_routes.dart`.
- [ ] **3.5 Codegen & Testing**
  - [ ] Run `serverpod generate && serverpod create-migration`.
  - [ ] Execute Serverpod repository unit tests (`baktaz_server/test/unit/challenge/challenge_repository_test.dart`) and endpoint integration tests (`baktaz_server/test/integration/challenge/challenge_endpoint_test.dart`) using `withServerpod` with stubbed payment/subscription repos.
  - [ ] Execute Flutter unit tests (`baktaz_flutter/test/unit/challenge_repository_test.dart`, `baktaz_flutter/test/unit/challenge_discovery_cubit_test.dart`, `baktaz_flutter/test/unit/challenge_detail_cubit_test.dart`, `baktaz_flutter/test/unit/challenge_create_cubit_test.dart`) and widget tests in `baktaz_flutter/test/widget/challenge/`.

---

### Feature 4: Payment (HitPay Gateway, Double-Entry Financial Ledger & Chopper Client)

**Goal:** Implement concrete payment gateway processing via HitPay HTTP client, double-entry financial ledger accounting, payout tracking models, and fulfill `IPaymentRepository`.

- [ ] **4.1 Double-Entry Ledger & Payout Models (`baktaz_server`)**
  - [ ] Create Double-Entry Financial Ledger models under `baktaz_server/lib/src/features/ledger/domain/model/`:
    - `LedgerAccount` (`ledger_account.spy.yaml`)
    - `LedgerTransaction` (`ledger_transaction.spy.yaml`)
    - `LedgerEntry` (`ledger_entry.spy.yaml`)
    - `TaxRule` (`tax_rule.spy.yaml`)
    - `AuditLog` (`audit_log.spy.yaml`)
  - [ ] Deprecate and remove legacy single-balance `Wallet` model in favor of double-entry ledger accounts.
  - [ ] Create payout tracking models under `baktaz_server/lib/src/features/payment/domain/model/`:
    - `Payment` (`payment.spy.yaml`)
    - `Payout` (`payout.spy.yaml`)
    - `HostPayout` (`host_payout.spy.yaml`)
    - `ChallengeWinner` (`challenge_winner.spy.yaml`)
    - `PaymentTransaction` (`payment_transaction.spy.yaml`)
    - `PaymentMethodInfo` (`payment_method_info.spy.yaml`)
- [ ] **4.2 Chopper Client & Services (`baktaz_server`)**
  - [ ] Implement `HitPayService` using Chopper HTTP client in `baktaz_server/lib/src/features/payment/data/service/hitpay_service.dart`.
  - [ ] Configure HitPay API credentials and request/response DTOs.
- [ ] **4.3 Serverpod Payment Webhook (`baktaz_server`)**
  - [ ] Implement HitPay Webhook endpoint (`HitPayWebhookRoute`) for async payment status callbacks.
- [ ] **4.4 Concrete PaymentRepository & Seam Swap (`baktaz_server` & `baktaz_flutter`)**
  - [ ] Implement `IPaymentRepository` in `baktaz_server/lib/src/features/payment/domain/interface/i_payment_repository.dart`.
  - [ ] Implement `PaymentRepository` in `baktaz_server/lib/src/features/payment/data/repository/payment_repository.dart` interacting with `LedgerRepository`.
  - [ ] Implement concrete `PaymentRepository` in `baktaz_flutter/lib/features/payment/data/repository/payment_repository.dart` fulfilling `baktaz_flutter/lib/features/payment/domain/interface/i_payment_repository.dart`.
  - [ ] Replace `StubPaymentRepository` with concrete `PaymentRepository` in `GetIt` / dependency container.
- [ ] **4.5 Flutter Payment Flow (`baktaz_flutter`)**
  - [ ] Create `PaymentCheckoutCubit` in `baktaz_flutter/lib/features/payment/presentation/cubit/payment_checkout_cubit.dart`.
  - [ ] Build `PaymentWebViewScreen` in `baktaz_flutter/lib/features/payment/presentation/views/payment_web_view_screen.dart` using `baktaz_shared` wrappers and `context.i18n.payment.*` keys.
  - [ ] Register typed route `@TypedGoRoute<PaymentCheckoutRoute>(path: '/payment/checkout')` for `PaymentWebViewScreen` in `baktaz_flutter/lib/app/routes/app_routes.dart`.
- [ ] **4.6 Codegen & Testing**
  - [ ] Run `serverpod generate && serverpod create-migration`.
  - [ ] Execute Serverpod repository unit tests (`baktaz_server/test/unit/payment/payment_repository_test.dart`, `baktaz_server/test/unit/ledger/ledger_repository_test.dart`) and endpoint/webhook integration tests (`baktaz_server/test/integration/payment/payment_endpoint_test.dart`, `baktaz_server/test/integration/payment/webhook_payment_test.dart`) using `withServerpod` verifying double-entry ledger transactions.
  - [ ] Execute Flutter unit tests (`baktaz_flutter/test/unit/payment_repository_test.dart`, `baktaz_flutter/test/unit/payment_checkout_cubit_test.dart`) and widget tests in `baktaz_flutter/test/widget/payment/`.

---

### Feature 5: Chat (Real-Time Messaging, Attachments, Events & Streams)

**Goal:** Implement real-time group and challenge chat with attachment uploads, system event messages, event templates, and Serverpod streaming connections.

- [ ] **5.1 Serverpod Chat Models & Schema (`baktaz_server`)**
  - [ ] Define `ChatMessage` in `baktaz_server/lib/src/features/chat/domain/model/chat_message.spy.yaml`.
  - [ ] Define `ChatRoom` in `baktaz_server/lib/src/features/chat/domain/model/chat_room.spy.yaml`.
  - [ ] Define `ChatParticipant` in `baktaz_server/lib/src/features/chat/domain/model/chat_participant.spy.yaml`.
  - [ ] Define `ChatAttachment` in `baktaz_server/lib/src/features/chat/domain/model/chat_attachment.spy.yaml`.
  - [ ] Define `EventMessage` in `baktaz_server/lib/src/features/chat/domain/model/event_message.spy.yaml`.
  - [ ] Define `EventTemplate` in `baktaz_server/lib/src/features/chat/domain/model/event_template.spy.yaml`.
- [ ] **5.2 Serverpod Endpoints & Presigned Uploads (`baktaz_server`)**
  - [ ] Implement `IChatRepository` in `baktaz_server/lib/src/features/chat/domain/interface/i_chat_repository.dart`.
  - [ ] Implement `ChatRepository` in `baktaz_server/lib/src/features/chat/data/repository/chat_repository.dart`.
  - [ ] Create `ChatEndpoint` / `MessageEndpoint` in `baktaz_server/lib/src/features/chat/endpoint/chat_endpoint.dart` extending `Endpoint` with `streamOpened`, `messageReceived`, `sendStreamMessage`, and presigned S3 photo upload method (`getUploadUrl()`).
  - [ ] Implement System Events Feed integration to dispatch automated milestone and challenge system event messages.
- [ ] **5.3 Server-Side Event Broadcasting (`baktaz_server`)**
  - [ ] Wire `session.messages.postMessage` for multi-session chat and event message dispatch.
- [ ] **5.4 Flutter Chat UI & Reactive Signals (`baktaz_flutter`)**
  - [ ] Implement `IChatRepository` in `baktaz_flutter/lib/features/chat/domain/interface/i_chat_repository.dart`.
  - [ ] Implement `ChatRepository` in `baktaz_flutter/lib/features/chat/data/repository/chat_repository.dart`.
  - [ ] Build `ChatCubit` in `baktaz_flutter/lib/features/chat/presentation/cubit/chat_cubit.dart` managing streaming message history, attachments, system events, and connection state.
  - [ ] Create `ChatRoomScreen` in `baktaz_flutter/lib/features/chat/presentation/views/chat_room_screen.dart` with optimistic message insertion, photo attachment support, system event feeds, and status indicators using `baktaz_shared` wrappers and `context.i18n.chat.*` keys.
  - [ ] Register typed route `@TypedGoRoute<ChatRoomRoute>(path: '/challenge/:id/chat')` for `ChatRoomScreen` in `baktaz_flutter/lib/app/routes/app_routes.dart`.
- [ ] **5.5 Codegen & Testing**
  - [ ] Run `serverpod generate && serverpod create-migration`.
  - [ ] Execute Serverpod repository unit tests (`baktaz_server/test/unit/chat/chat_repository_test.dart`) and endpoint integration tests (`baktaz_server/test/integration/chat/chat_endpoint_test.dart`) using `withServerpod` for streaming connections.
  - [ ] Execute Flutter unit tests (`baktaz_flutter/test/unit/chat_repository_test.dart`, `baktaz_flutter/test/unit/chat_cubit_test.dart`) and widget tests in `baktaz_flutter/test/widget/chat/`.

---

### Feature 6: Manage Payment & Payout Destinations (Saved Payment Methods & Payout Destinations)

**Goal:** Enable users to view, save, set default, and delete saved payment methods and payout destinations.

- [ ] **6.1 Serverpod Endpoints & Data Model (`baktaz_server`)**
  - [ ] Reuse `PaymentMethodInfo` model from `baktaz_server/lib/src/features/payment/domain/model/payment_method_info.spy.yaml` (created in Feature 4); do not create duplicate model file under `manage_payment/`.
  - [ ] Define `PayoutDestination` model in `baktaz_server/lib/src/features/manage_payment/domain/model/payout_destination.spy.yaml`.
  - [ ] Implement `IManagePaymentRepository` in `baktaz_server/lib/src/features/manage_payment/domain/interface/i_manage_payment_repository.dart`.
  - [ ] Implement `ManagePaymentRepository` in `baktaz_server/lib/src/features/manage_payment/data/repository/manage_payment_repository.dart`.
  - [ ] Expose `ManagePaymentEndpoint` in `baktaz_server/lib/src/features/manage_payment/endpoint/manage_payment_endpoint.dart` (`listMethods`, `addMethodToken`, `setDefaultMethod`, `removeMethod`).
  - [ ] Implement `IPayoutRepository` in `baktaz_server/lib/src/features/manage_payment/domain/interface/i_payout_repository.dart`.
  - [ ] Implement `PayoutRepository` in `baktaz_server/lib/src/features/manage_payment/data/repository/payout_repository.dart`.
  - [ ] Expose `PayoutEndpoint` in `baktaz_server/lib/src/features/manage_payment/endpoint/payout_endpoint.dart` (`listDestinations`, `addDestination`, `removeDestination`).
- [ ] **6.2 Flutter Presentation & State (`baktaz_flutter`)**
  - [ ] Implement `IManagePaymentRepository` in `baktaz_flutter/lib/features/manage_payment/domain/interface/i_manage_payment_repository.dart`.
  - [ ] Implement `ManagePaymentRepository` in `baktaz_flutter/lib/features/manage_payment/data/repository/manage_payment_repository.dart`.
  - [ ] Implement `IPayoutRepository` in `baktaz_flutter/lib/features/manage_payment/domain/interface/i_payout_repository.dart`.
  - [ ] Implement `PayoutRepository` in `baktaz_flutter/lib/features/manage_payment/data/repository/payout_repository.dart`.
  - [ ] Create `ManagePaymentCubit` in `baktaz_flutter/lib/features/manage_payment/presentation/cubit/manage_payment_cubit.dart`.
  - [ ] Build `ManagePaymentScreen` in `baktaz_flutter/lib/features/manage_payment/presentation/views/manage_payment_screen.dart` using `baktaz_shared` wrappers and `context.i18n.manage_payment.*` keys.
  - [ ] Build `PaymentMethodTile` in `baktaz_flutter/lib/features/manage_payment/presentation/widgets/payment_method_tile.dart` using `baktaz_shared` wrappers and `context.i18n.manage_payment.*` keys.
  - [ ] Build `AddPaymentMethodDialog` in `baktaz_flutter/lib/features/manage_payment/presentation/widgets/dialogs/add_payment_method_dialog.dart` using `baktaz_shared` wrappers and `context.i18n.manage_payment.*` keys.
  - [ ] Build `AddPayoutDestinationDialog` in `baktaz_flutter/lib/features/manage_payment/presentation/widgets/dialogs/add_payout_destination_dialog.dart` using `baktaz_shared` wrappers and `context.i18n.manage_payment.*` keys.
  - [ ] Register typed route `@TypedGoRoute<ManagePaymentRoute>(path: '/account/payment')` for `ManagePaymentScreen` in `baktaz_flutter/lib/app/routes/app_routes.dart`.
- [ ] **6.3 Codegen & Testing**
  - [ ] Run `serverpod generate && serverpod create-migration`.
  - [ ] Execute Serverpod repository unit tests (`baktaz_server/test/unit/manage_payment/manage_payment_repository_test.dart`, `baktaz_server/test/unit/manage_payment/payout_repository_test.dart`) and endpoint integration tests (`baktaz_server/test/integration/manage_payment/manage_payment_endpoint_test.dart`, `baktaz_server/test/integration/manage_payment/payout_endpoint_test.dart`) using `withServerpod`.
  - [ ] Execute Flutter unit tests (`baktaz_flutter/test/unit/manage_payment_repository_test.dart`, `baktaz_flutter/test/unit/payout_repository_test.dart`, `baktaz_flutter/test/unit/manage_payment_cubit_test.dart`) and widget tests (`baktaz_flutter/test/widget/manage_payment/payment_method_tile_test.dart`).

---

### Feature 7: Subscription (Recurring Billing, Voucher Engine & Account Integration)

**Goal:** Implement subscription tiers, recurring billing, voucher discounts, and update user `isPremium` status on `AccountSummary`.

- [ ] **7.1 Serverpod Subscription & Voucher Models (`baktaz_server`)**
  - [ ] Define `SubscriptionPlan` in `baktaz_server/lib/src/features/subscription/domain/model/subscription_plan.spy.yaml`.
  - [ ] Define `UserSubscription` in `baktaz_server/lib/src/features/subscription/domain/model/user_subscription.spy.yaml`.
  - [ ] Define `VoucherCode` in `baktaz_server/lib/src/features/subscription/domain/model/voucher_code.spy.yaml`.
- [ ] **7.2 Backend Services & Host Cut Calculation (`baktaz_server`)**
  - [ ] Implement `VoucherEngine` in `baktaz_server/lib/src/features/subscription/domain/service/voucher_engine.dart` for promo code validation and discount calculation.
  - [ ] Embed host cut calculation and forfeiture logic directly inside `ChallengeRepository.calculatePayoutLedger` in `baktaz_server` (evaluating host subscription tier to apply or forfeit host cut without standalone service overhead).
  - [ ] Implement `ISubscriptionRepository` in `baktaz_server/lib/src/features/subscription/domain/interface/i_subscription_repository.dart`.
  - [ ] Implement `SubscriptionRepository` in `baktaz_server/lib/src/features/subscription/data/repository/subscription_repository.dart`.
  - [ ] Expose `SubscriptionEndpoint` in `baktaz_server/lib/src/features/subscription/endpoint/subscription_endpoint.dart`.
  - [ ] Update `AccountSummary.isPremium` dynamically upon subscription activation/cancellation.
- [ ] **7.3 Flutter Subscription UI & Concrete Seam Swap (`baktaz_flutter`)**
  - [ ] Implement concrete `SubscriptionRepository` in `baktaz_flutter/lib/features/subscription/data/repository/subscription_repository.dart` fulfilling `baktaz_flutter/lib/features/account/domain/interface/i_host_subscription_repository.dart`.
  - [ ] Replace `StubHostSubscriptionRepository` with concrete `SubscriptionRepository` in DI container.
  - [ ] Create `SubscriptionCubit` in `baktaz_flutter/lib/features/subscription/presentation/cubit/subscription_cubit.dart`.
  - [ ] Create `VoucherCubit` in `baktaz_flutter/lib/features/subscription/presentation/cubit/voucher_cubit.dart`.
  - [ ] Build `SubscriptionPaywallScreen` in `baktaz_flutter/lib/features/subscription/presentation/views/subscription_paywall_screen.dart` using `baktaz_shared` wrappers and `context.i18n.subscription.*` keys.
  - [ ] Build `VoucherRedeemDialog` in `baktaz_flutter/lib/features/subscription/presentation/widgets/dialogs/voucher_redeem_dialog.dart` using `baktaz_shared` wrappers and `context.i18n.subscription.*` keys.
  - [ ] Register typed route `@TypedGoRoute<SubscriptionPaywallRoute>(path: '/subscription')` for `SubscriptionPaywallScreen` in `baktaz_flutter/lib/app/routes/app_routes.dart`.
- [ ] **7.4 Codegen & Verification**
  - [ ] Run `serverpod generate && serverpod create-migration`.
  - [ ] Execute Serverpod repository unit tests (`baktaz_server/test/unit/subscription/subscription_repository_test.dart`) and endpoint integration tests (`baktaz_server/test/integration/subscription/subscription_endpoint_test.dart`) using `withServerpod`.
  - [ ] Execute Flutter unit tests (`baktaz_flutter/test/unit/subscription_repository_test.dart`, `baktaz_flutter/test/unit/subscription_cubit_test.dart`, `baktaz_flutter/test/unit/voucher_cubit_test.dart`) and widget tests in `baktaz_flutter/test/widget/subscription/`.
  - [ ] Run full monorepo integration test suite across all 7 feature slices.

---

## 4. Summary Matrix of Seams & Dependencies

| Feature Slice | Key Models Introduced / Updated | Dependencies Required | Interfaces / Seams Exposed / Implemented |
|---|---|---|---|
| **Step 0: Infra** | `ConfigKey`, `TargetingOverride`, `ConfigSnapshotVersion`, `PublicConfigVersion`, `RemoteConfigDefaultValue`, `RemoteConfigValue`, `RemoteConfig`, `RemoteConfigValueType`, `RemoteLocalizationRelease`, `RemoteLocalizationAuditLog`, `RemoteLocalizationResponse` | None | `IRemoteConfigRepository`, `IRemoteLocalizationRepository` |
| **Feature 1: Account+Profile** | `UserInfo` (updated), `AccountSummary` | Step 0 | `IAccountRepository`, `IProfileRepository`; username auto-derivation via `UsernameUtils` |
| **Feature 2: Steps** | `UserDevice`, `HealthIntegration`, `StepSync`, `DailyStepTelemetry` | Feature 1 | `IStepRepository` |
| **Feature 3: Challenge** | `ChallengeConfig`, `Challenge`, `ChallengeParticipant`, `ChallengeLeaderboard` (transient DTO) | Feature 1, Feature 2 | Declares `IPaymentRepository` & `IHostSubscriptionRepository` (Stubbed); Scheduled Lifecycle Jobs (`ChallengePhaseTransitionJob`, `ChallengePayoutCalculationJob`) |
| **Feature 4: Payment** | `LedgerAccount`, `LedgerTransaction`, `LedgerEntry`, `TaxRule`, `AuditLog` (ledger); `Payment`, `Payout`, `HostPayout`, `ChallengeWinner`, `PaymentTransaction`, `PaymentMethodInfo`; Legacy `Wallet` (removed) | Feature 3 | Implements `IPaymentRepository` (Replaces Stub); Double-Entry Ledger with payout tracking; `LedgerRepository` |
| **Feature 5: Chat** | `ChatMessage`, `ChatRoom`, `ChatParticipant`, `ChatAttachment`, `EventMessage`, `EventTemplate` | Feature 1, Feature 3 | `IChatRepository`; Presigned S3 upload via `MessageEndpoint.getUploadUrl()`; System Events Feed |
| **Feature 6: Manage Payment & Payout Destinations** | `PaymentMethodInfo` (reused), `PayoutDestination` | Feature 4 | `IManagePaymentRepository`, `IPayoutRepository` |
| **Feature 7: Subscription** | `SubscriptionPlan`, `UserSubscription`, `VoucherCode` | Feature 4, Feature 6 | Implements `IHostSubscriptionRepository` (Replaces Stub); Updates `AccountSummary.isPremium`; Embedded Host Cut in `ChallengeRepository.calculatePayoutLedger` |

---

## 5. Handoff Checklist

- [x] All 10 feature plan suites mapped and sequenced.
- [x] Step 0 exact model filenames and classes updated.
- [x] Architecture seams (`IPaymentRepository`, `IHostSubscriptionRepository`) explicitly specified and paths assigned.
- [x] Canonical file locations provided per task.
- [x] Account and Profile models consolidated (`UserInfo`, `AccountSummary.isPremium`).
- [x] Single `serverpod generate` + migration per vertical slice enforced.
- [x] Implementation-First testing rule preserved across all steps.
- [x] Section 2.7 Defensive Architecture & Anti-Bug Invariants integrated (step anti-cheat, financial webhook idempotency, resource safety).
- [x] Section 2.8 Server-Side Security, Boundary Input Validation & Idempotency Invariants integrated (auth identity derivation, boundary RPC input checks, server-side idempotency).
- [ ] Section 2.9 Phase Review Gates & User Verification Invariants integrated (mandatory pause, review output, explicit user approval, no auto-commits).
- [x] Section 2.10 Out-of-Scope Items & Canonical TODO Markers integrated (secrets & credentials, baktaz_admin UI, secondary health integrations).
