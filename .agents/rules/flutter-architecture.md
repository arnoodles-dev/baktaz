---
trigger: glob
description: Directory structure, feature organization, Cubit/Repo layers, and routing in Flutter
globs: *_flutter/lib/**, *_admin/lib/**, *_shared/lib/**, lib/**
---

# Flutter Architecture

### Directory Structure

- Dirs: `app/`, `core/`, `features/`, `*_shared/`
- Feature structure: `data/`, `domain/`, `presentation/`

### Layers

- **Cubit**: Annotate DI, extend `Cubit<S>`. Methods single-action only (no "god methods"). Emit view states, only call repo, no data aggregation. Wrap try-catch in `safeRun(onException: handleException)`.
- **State**: Sealed classes for exclusive states; classic classes with `copyWith` for continuous forms.
- **Side Effects**: Use `bloc_presentation` for one-off UI events (navigation, dialogs, snackbars).
- **Error**: Match repo result, avoid raw try/catch in UI.
- **Repo**: `@LazySingleton(as: Interface)`. Return `TaskResult<T>`, never throw. Wrap try-catch in `TaskResult.tryCatch`. Use `fold` to handle failures. Own all business/data logic (aggregation, sorting, slicing). Mock data with `Future.delayed` wrapped in `TaskResult`. Wrap primitives in domain-specific Value Objects at repo boundary.
- **Domain & DTO Modeling**: Lean (no wrapper class if it only holds a single primitive/value object). Value Objects used in domain entities; DTOs use primitives only. Add `validate()` to all domain entities; validate before persisting or processing.
- **Screens**: Prefer `StatelessWidget` or `HookWidget` (from `flutter_hooks`). No business logic. Do not return Widget from helper methods; extract reusable UI into its own widget class. Do not use ternary hell for conditional rendering; use `if` inside collection literals for clean conditional UI.
- **Routing**: `go_router` + `go_router_builder` typed routes; auth via `RouteGuard`.
- **DI**: `getIt` + `injectable` (auto-register via annotations).

### Feature Structure (`lib/features/<feature>/`)
- Must have `data/`, `domain/`, `presentation/`.
- `presentation/views/` (screens/pages) + `widgets/`.
- Dialogs must be placed in `presentation/widgets/dialogs/` folder and follow the naming convention (snake_case.dart with `_dialog` suffix).
- `domain/cubit/` (injectable), `entity/` (freezed), `interface/`.
- `data/repository/` (LazySingleton), `service/` (Chopper), `dto/` (freezed).

### Tooling
- **Forbidden**: Serverpod legacy packages (`serverpod_auth_*`). Other Serverpod packages are allowed.
- **Libs**: `fpdart`, `trust_but_verify`, `envied`, `chopper`.
- **Assets**: `dart run icons_launcher:create`, `dart run flutter_native_splash:create`.

### Feature Workflow

1. Presentation (Screen/Widgets)
2. Route (`@TypedGoRoute`)
3. Cubit/States
4. Domain Entities
5. Repo Interface
6. Repo Implementation
7. DTOs
8. i18n keys
9. Codegen (`slang` + `build_runner`)
