# Monorepo Agent Contract — Baktaz

This repository is a Flutter and Serverpod monorepo consisting of backend services, admin web/desktop management tools, client applications, and shared UI design systems.

---

## Monorepo Architecture & Packages

### 1. `baktaz_server` (Serverpod Backend)
- **Framework**: Serverpod 2.x backend server running on Dart.
- **Role**: Primary backend API, database ORM layer, authentication provider, and administrative infrastructure.
- **Capabilities & Infrastructure**:
  - **Admin Infrastructure**: Built on `AdminEndpointBase` requiring `Scope.admin`. Provides `AdminEndpoint` for admin user listing (`listAdminUsers`, `listAuthUsers`), blocking/unblocking accounts (`blockUser`, `unblockUser`), and scope management (`updateUserScope`).
  - **Auth & Identity**: Integrated identity provider endpoints (`EmailIdpEndpoint`, `GoogleIdpEndpoint`, `FacebookIdpEndpoint`, `JwtRefreshEndpoint`) powered by `AuthUtils` and `AdminRepository`. Automatic admin user seeding via `SeedingUtils`.
  - **Account & Core Services**: `AccountEndpoint` managing accounts, profiles, addresses, contacts, user states, and wallets.
  - **Data Models**: Defined in `.spy.yaml` (`account`, `account_summary`, `address`, `contact`, `user_info`, `profile`, `account_state`, `wallet`, `wallet_transactions`).
  - **Dependency Injection**: `injectable` + `getIt` (`lib/src/app/injection/service_locator.dart`).

### 2. `baktaz_admin` (Flutter Admin Web & Desktop)
- **Framework**: Flutter Web/Desktop application built with clean architecture (Data, Domain, Presentation layers).
- **Role**: Administration dashboard for managing users, system analytics, content, localization, and remote configuration.
- **Ported Features**:
  - **Auth**: Admin authentication, credentials login (`LoginScreen`), JWT token management, and session state via `AuthCubit` & `LoginCubit`.
  - **Dashboard**: System overview (`DashboardScreen`), key metrics (`DashboardStats`), daily activity analytics (`DailyActivityStats`), category reports (`CategoryReportStats`), and activity filtering (`TimeFilter`, `ActivityStatusFilter`).
  - **Localization**: Key-value translation management (`LocalizationScreen`), tree hierarchy builder (`LocalizationTreeBuilder`), translation sorting (`LocalizationSortCriteria`), and modal dialogs (`AddTranslationDialog`, `EditTranslationDialog`).
  - **Remote Config**: Real-time parameter control (`RemoteConfigScreen`), parameter grouping (`RemoteConfigGroup`), target environment percentage rollouts (`RemoteConfigParameter`).
  - **Content**: Content asset management (`ContentScreen`), asset status lifecycles (`ContentStatus`), asset types (`ContentAssetType`), and placement group rules (`ContentPlacementGroup`).

### 3. `baktaz_flutter` (Main Flutter Client)
- **Framework**: Flutter multi-platform application (iOS, Android, Web).
- **Role**: User-facing application interfacing with `baktaz_server` backend via `baktaz_client`.

### 4. `baktaz_shared` (Design System & Reusable Components)
- **Framework**: Shared Flutter UI package.
- **Role**: Centralized UI component library (`BaktazText`, `BaktazButton`, `BaktazTextField`, `BaktazCard`, `BaktazAppBar`, `Paddings`, `AppSizes`), design tokens (`DESIGN.md`), and shared utilities.

### 5. `baktaz_client` (Generated Serverpod SDK)
- **Role**: Auto-generated client library produced by `serverpod generate` for strongly-typed client-server RPC communication.

---

## Serverpod & Execution Rules

- The user starts the server and Flutter apps with `serverpod start`. **NEVER** start the server yourself; instead **STOP** and ask the user to start it if not running.
- When the server is running, interact with it through the `serverpod` MCP. `serverpod start` automatically handles hot reload for both the server and Flutter apps as files change.

### MCP Tools Usage
ALWAYS use the MCP server instead of CLI where applicable:
- `create_migration` and `apply_migrations`: Database schema updates after model (`.spy.yaml`) edits.
- `tail_server_logs`: Read stdout/stderr logs from the Serverpod server.
- `tail_flutter_logs`: Read raw stdout/stderr logs from running Flutter applications.
- `hot_restart`: Restart the server isolate and connected Flutter apps after structural changes.
- `get_flutter_app_dtd`: Retrieve Dart Tooling Daemon (DTD) URIs for Flutter driver debugging.

---

## Verification & Quality Checklist

After making code changes, run the following verification steps:

1. `dart analyze` (CLI across package targets)
2. `dart format` (CLI across modified files)
3. `create_migration` and `apply_migrations` (MCP — when `.spy.yaml` data models change)
4. `hot_restart` (`serverpod` MCP — when hot reload is insufficient or Flutter app reconnect is required)
5. Run tests (`dart test` / `flutter test` CLI)
6. Verify logs via `tail_server_logs` and `tail_flutter_logs` (`serverpod` MCP)

---

## Automated App Testing via DTD

If asked to test the Flutter app:
1. Call `get_flutter_app_dtd` (`serverpod` MCP) to obtain the app DTD URI.
2. Call `connect` (`dart_mcp_server_dtd` MCP) with the returned DTD URI.
3. Use `flutter_driver_command` (`dart-mcp-server` MCP) to inspect widgets and navigate screens.
