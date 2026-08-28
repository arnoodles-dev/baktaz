---
trigger: glob
description: Flutter directory structure, feature organization, Cubit/Repo layers, Service/Repository separation, and routing
globs: *_flutter/lib/**, *_admin/lib/**, *_shared/lib/**, lib/**
---

# Flutter Architecture

## Directory Structure

- Dirs: `app/`, `core/`, `features/`, `*_shared/`
- Feature: `data/`, `domain/`, `presentation/`
- `presentation/views/` (screens/pages) + `widgets/`
- Dialogs: `presentation/widgets/dialogs/` with `_dialog` suffix

## Screen vs Page

- **Screen** — full view that does **not** live inside a nav bar or tab bar. Navigated to via route (e.g., detail, create, success).
- **Page** — view that **lives inside** a nav bar or tab bar (e.g., one tab of a `BottomNavigationBar` or `TabBar`).

**Naming:**
- Screen files end in `_screen.dart` (e.g., `challenge_create_screen.dart`)
- Page files end in `_page.dart` (e.g., `challenge_page.dart`)

**Example:**
```
ChallengePage          ← Page (lives in BottomNavigationBar tab)
  └── ChallengeDetailScreen  ← Screen (navigated to from page)
  └── ChallengeLeaderboardPage  ← Page (nested tab bar)
```

## Layers

### Cubit
- Extend `CubitSignal<S>` (or `BlocSignal<E, S>`)
- Require `initialState:` named constructor
- Access raw state via `stateValue`, expose reactive signal via `state`
- Single-action methods only (no "god methods")
- Only call repo, no data aggregation
- Wrap try-catch in `safeRun(onException: handleException)`

### Provider Ownership
- `@lazySingleton` Cubits: `BlocSignalProvider.value(value: getIt<T>())`
- `@injectable` Cubits: `BlocSignalProvider(create: (_) => getIt<T>())`

### State
- Sealed classes for exclusive states
- Classic classes with `copyWith` for continuous forms
- **Error handling**: see error-handling-architecture.md (Pattern B — side effects only, no Failure in state)

### Repo
- `@LazySingleton(as: Interface)`
- Return `TaskResult<T>`, never throw
- Wrap try-catch in `TaskResult.tryCatch`
- Use `fold` to handle failures

## Feature Structure

See `.agents/reference/flutter-feature-structure.md` for complete directory tree and naming conventions.

## Routing

`go_router` + `go_router_builder` typed routes with `RouteGuard` for auth.

## Tooling

- **Allowed**: `fpdart`, `trust_but_verify`, `envied`, `chopper`, `bloc_signals`, `bloc_signals_flutter`, `signals_hooks`, `serverpod_auth_idp_flutter*`

## Feature Workflow

1. Presentation (Screen/Widgets)
2. Route (`@TypedGoRoute`)
3. Cubit/States
4. Domain Entities
5. Repo Interface
6. Repo Implementation
7. DTOs
8. I18n keys
9. Codegen — see operations.md for full codegen order

See `.agents/reference/flutter-feature-workflow.md` for step-by-step guide.

---

## Service vs Repository

### Service
- Talks directly to external integration (HTTP, packages, platform APIs)
- Owns **how** — no business logic
- Examples: HitPay HTTP client, Chopper client, platform-specific SDK wrapper
- Located in: `data/service/`

### Repository
- Orchestrates one or more services (injected via getIt/injectable)
- Owns **what** — exposes clean domain API to BLoCs/Cubits
- Examples: PaymentRepository, PayoutRepository, ChallengeRepository
- Located in: `data/repository/`

### Rule of Thumb
- If it's talking to something outside the app, it's a **Service**
- If it's deciding what to do with that data, it's a **Repository**
- BLoCs/Cubits should only depend on **Repositories**, never Services

### Dependency Chain

```
Cubit → Repository → Service → External (HTTP, SDK, Platform)
```

### Naming Convention
- Services: `<Name>Service` (e.g., `HitPayService`, `ChopperService`)
- Repositories: `<Name>Repository` (e.g., `PaymentRepository`, `PayoutRepository`)
- Repository interfaces: `I<Name>Repository` (e.g., `IPaymentRepository`)
