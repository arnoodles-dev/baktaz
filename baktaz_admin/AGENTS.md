# Package Contract — baktaz_admin

`baktaz_admin` is the Flutter Web & Desktop management dashboard for the Baktaz ecosystem, providing administrative tools for managing users, analytics, localization, remote configurations, and content assets.

---

## Architecture & Design Patterns

- **Pattern**: Clean Architecture (Data, Domain, Presentation layers) per feature under `lib/features/<feature>/`.
- **State Management**: `Cubit` extending `Cubit<State>` using `freezed` for immutable union states. Side-effects via `bloc_signals`.
- **Dependency Injection**: `getIt` + `injectable` annotations registered in `lib/app/helpers/injection/service_locator.dart`.
- **Routing**: `go_router` declaratively managed in `lib/app/routes/app_router.dart`.
- **Design System**: Consumes `baktaz_shared` UI components (`BaktazText`, `BaktazButton`, `BaktazTextField`, `BaktazCard`, `BaktazAppBar`, `Paddings`, `AppSizes`).
- **Localization**: Powered by `slang` (`lib/gen/strings.g.dart`). User-facing strings must not be hardcoded.

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

## DOX Compliance

This is a binding DOX contract. Read before editing `baktaz_admin/` paths.
Walk the DOX chain: root → `baktaz_flutter/` → child. Closer docs control local details.
Update this file when purpose, scope, or workflows change.
