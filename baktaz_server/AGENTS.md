# Package Contract — baktaz_server

`baktaz_server` is the Serverpod 2.x backend server for the Baktaz ecosystem, delivering API endpoints, database ORM entities, authentication services, and admin infrastructure.

---

## Architecture & Server Infrastructure

- **Framework**: Serverpod 2.x running on Dart.
- **Directory Structure**:
  - `bin/main.dart` — Server entry point.
  - `lib/server.dart` — Server initialization and module configuration.
  - `lib/src/features/` — Feature modules containing endpoints, domain repositories, and `.spy.yaml` models.
  - `lib/src/core/` — Infrastructure base classes (e.g., `AdminEndpointBase`).
- **Dependency Injection**: `getIt` + `injectable` configured in `lib/src/app/injection/service_locator.dart`.
- **Database ORM**: Strongly-typed model definitions in `.spy.yaml` files compiled via `serverpod generate`.
- **Configuration**: `lib/src/app/config/app_config.dart` using `AppConfig`.

---

## Endpoints & Administrative Infrastructure

### 1. Admin Endpoint (`lib/src/features/auth/endpoint/admin_endpoint.dart`)
- **Base Class**: `AdminEndpointBase` (`requireLogin = true`, `requiredScopes = {Scope.admin}`).
- **Repository**: `IAdminRepository` / `AdminRepository`.
- **Operations**:
  - `listAdminUsers(session)` — List all administrative user accounts.
  - `listAuthUsers(session)` — List all registered authentication user accounts.
  - `blockUser(session, authUserId)` — Block a user account by UUID.
  - `unblockUser(session, authUserId)` — Unblock a user account by UUID.
  - `updateUserScope(session, authUserId, scopeNames)` — Update assigned authorization scopes.

### 2. Authentication & Identity Providers (`lib/src/features/auth/endpoint/`)
- `EmailIdpEndpoint` — Email/Password authentication flow.
- `GoogleIdpEndpoint` — Google OAuth authentication flow.
- `FacebookIdpEndpoint` — Facebook OAuth authentication flow.
- `JwtRefreshEndpoint` — JWT token refresh mechanism.
- **Utilities**: `AuthUtils` for session token validation, `SeedingUtils` for automated initial admin account seeding.

### 3. Account & Core Endpoints (`lib/src/features/account/endpoint/`)
- `AccountEndpoint` — Manages user accounts, profiles, addresses, contacts, user states, and wallets.

---

## Data Models (`.spy.yaml`)

- `account` & `account_summary` — User account state and aggregated summaries.
- `address` — User physical address data.
- `contact` — Contact details and phone numbers.
- `user_info` — User details.
- `profile` — Profile metadata and preferences.
- `account_state` — Active/blocked/pending state flags.
- `wallet` & `wallet_transactions` — Financial balance and transaction ledger.

---

## Verification & Quality Checklist

Run the following checks after modifying `baktaz_server`:

1. **Linting**:
   ```bash
   dart analyze baktaz_server
   ```
2. **Formatting**:
   ```bash
   dart format baktaz_server/lib baktaz_server/test
   ```
3. **Database Migrations (MCP)**:
   - When `.spy.yaml` models change, run `create_migration` followed by `apply_migrations` using the `serverpod` MCP.
4. **Server Restart & Logs (MCP)**:
   - Run `hot_restart` via `serverpod` MCP to reload server isolate changes.
   - Monitor backend logs with `tail_server_logs` (`serverpod` MCP).
5. **Tests**:
   ```bash
   make test_server
   ```
