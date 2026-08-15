# Package Contract — baktaz_admin

`baktaz_admin` is the Flutter Web & Desktop management dashboard for the Baktaz ecosystem, providing administrative tools for managing users, analytics, localization, remote configurations, and content assets.

---

## Architecture & Design Patterns

- **Pattern**: Clean Architecture (Data, Domain, Presentation layers) per feature under `lib/features/<feature>/`.
- **State Management**: `Cubit` extending `Cubit<State>` using `freezed` for immutable union states. Side-effects via `bloc_presentation`.
- **Dependency Injection**: `getIt` + `injectable` annotations registered in `lib/app/helpers/injection/service_locator.dart`.
- **Routing**: `go_router` declaratively managed in `lib/app/routes/app_router.dart`.
- **Design System**: Consumes `baktaz_shared` UI components (`BaktazText`, `BaktazButton`, `BaktazTextField`, `BaktazCard`, `BaktazAppBar`, `Paddings`, `AppSizes`).
- **Localization**: Powered by `slang` (`lib/gen/strings.g.dart`). User-facing strings must not be hardcoded.

---

## Ported Feature Modules

### 1. Auth (`lib/features/auth/`)
- **Presentation**: `LoginScreen` (`presentation/views/login_screen.dart`).
- **State Management**: `AuthCubit` (session guard & auth state), `LoginCubit` (credentials input & submit).
- **Domain & Data**: `IAuthRepository`, `AuthRepository`. JWT token storage and session validation.

### 2. Dashboard (`lib/features/dashboard/`)
- **Presentation**: `DashboardScreen` (`presentation/views/dashboard_screen.dart`).
- **State Management**: `DashboardCubit`, `DashboardState`.
- **Entities**: `DashboardStats` (total users, active sessions, system load), `DailyActivityStats`, `CategoryReportStats`, `RecentActivity`.
- **Filters**: `TimeFilter` (today, week, month, year), `ActivityFilter`, `ActivityStatusFilter` (`ActivityStatus.success`, `pending`, `failed`).

### 3. Localization (`lib/features/localization/`)
- **Presentation**: `LocalizationScreen` (`presentation/views/localization_screen.dart`), `LocalizationTableWidget`, `AddTranslationDialog`, `EditTranslationDialog`.
- **State Management**: `LocalizationCubit`, `LocalizationState`.
- **Entities**: `LocalizationKey`, `LocalizationTranslation`, `LocalizationTreeBuilder` (hierarchical key-value tree generation), `LocalizationSortCriteria` (sorting by key, namespace, or status).

### 4. Remote Config (`lib/features/remote_config/`)
- **Presentation**: `RemoteConfigScreen` (`presentation/views/remote_config_screen.dart`).
- **State Management**: `RemoteConfigCubit`, `RemoteConfigState`.
- **Entities**: `RemoteConfigParameter` (key, value, type, rollout percentage), `RemoteConfigGroup` (parameter categorizations).

### 5. Content (`lib/features/content/`)
- **Presentation**: `ContentScreen` (`presentation/views/content_screen.dart`), `ContentAssetTable`, `ContentConfigPanel`.
- **State Management**: `ContentCubit`, `ContentState`.
- **Entities**: `ContentAsset`, `ContentStatus` (`draft`, `published`, `archived`), `ContentAssetType` (`banner`, `popup`, `inline`), `ContentPlacementGroup`.

---

## Assets & Configuration

- Assets configuration: `pubspec.yaml`, `icons_launcher.yaml`, `flutter_native_splash.yaml`.
- Web assets in `web/` (`index.html`, `manifest.json`, `favicon.png`).

---

## Verification & Quality Checklist

Run the following checks after modifying `baktaz_admin`:

1. **Linting & Code Quality**:
   ```bash
   dart analyze baktaz_admin
   dcm analyze baktaz_admin
   ```
2. **Formatting**:
   ```bash
   dart format baktaz_admin/lib baktaz_admin/test
   ```
3. **Tests**:
   ```bash
   make test_admin
   ```
4. **App Reload & Logs (Serverpod MCP)**:
   - Use `hot_restart` via `serverpod` MCP to reload the web/desktop client isolate.
   - Monitor runtime errors with `tail_flutter_logs` (`serverpod` MCP).
