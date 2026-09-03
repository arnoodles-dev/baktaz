# Package Contract — baktaz_admin

`baktaz_admin` is the Flutter Web & Desktop management dashboard for the Baktaz ecosystem, providing administrative tools for managing users, analytics, localization, remote configurations, and content assets.

---

## Architecture & Design Patterns

- **Pattern**: Clean Architecture (Data, Domain, Presentation layers) per feature under `lib/features/<feature>/`.
- **State Management**: `Cubit` extending `Cubit<State>` using `freezed` for immutable union states. Side-effects via `bloc_signals`.
- **Dependency Injection**: `getIt` + `injectable` annotations registered in `lib/app/helpers/injection/service_locator.dart`.
- **Routing**: `go_router` declaratively managed in `lib/app/routes/app_router.dart`.
- **Design System**: Consumes `baktaz_shared` UI components (`BaktazText`, `BaktazButton`, `BaktazTextField`, `BaktazCard`, `BaktazAppBar`, `Paddings`, `AppSizes`).
- **Localization**: Powered by `slang` (`lib/app/generated/localization.g.dart`). User-facing strings must not be hardcoded (see `.agents/rules/localization.md`).

---

## Feature Modules

- **Auth**: Login, session management, JWT tokens.
- **Dashboard**: System metrics, activity analytics, filtering.
- **Localization**: Key-value translations, hierarchical tree builder.
- **Remote Config**: Parameter rollouts, grouping.
- **Content**: Asset management, status lifecycle, placement rules.


## Verification

See `.agents/rules/operations.md` for verification commands and MCP tools.

---

## Child DOX Index

- `.agents/rules/flutter-architecture.md` — structure, layers, routing
- `.agents/rules/state-management-architecture.md` — Signals/Cubit/Bloc decisions
- `.agents/rules/error-handling-architecture.md` — Failure taxonomy, Pattern B
- `.agents/rules/design-system.md` — UI wrappers, typography, colors
- `.agents/rules/localization.md` — Slang i18n, JSON structure, AppLocalizationCubit
- `.agents/rules/optimization.md` — Flutter performance rules

---

## DOX Compliance

This is a binding DOX contract. Read before editing `baktaz_admin/` paths.
Walk the DOX chain: root → `baktaz_flutter/` → child. Closer docs control local details.
Update this file when purpose, scope, or workflows change.
