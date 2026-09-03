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

## Endpoints

- Admin endpoints (`AdminEndpointBase`, `Scope.admin`): user management, blocking, scoping.
- Auth endpoints: email/password, Google OAuth, Facebook OAuth, JWT refresh.
- AccountEndpoint (`lib/src/features/account/endpoint/account_endpoint.dart`):
  - `getSummary(Session)` -> `AccountSummary`
  - `deleteAccount(Session)` -> `void` (requires login)
- ProfileEndpoint (`lib/src/features/profile/endpoint/profile_endpoint.dart`):
  - `getProfile(Session)` -> `UserInfo?`
  - `updateProfile(Session, firstName?, lastName?, username?)` -> `UserInfo?`
  - `checkUsernameAvailability(Session, username)` -> `bool` (requires login)

---

## Data Models

Defined in `.spy.yaml` files under `lib/src/features/account/domain/model/`:
- `UserInfo` (`user_info` table): Core user identity, email, username (unique index), mobile, name, gender, dates.
- `AccountSummary`: Aggregated account metric snapshot (`userId`, `isPremium`, `totalSteps`, `activeChallengeCount`).
- `Profile`: User profile presentation model (`fullName`, `gender`, `email`, `mobileNumber`, `birthday`, `age`, `imageUrl`, `updatedAt`).
- Additional entities: `Account`, `AccountState`, `Address`, `Contact`, `Wallet`.

---

## Services & Repositories

- `IAccountRepository` / `AccountRepository`: Backend account data operations (summary retrieval, account deletion).
- `IProfileRepository` / `ProfileRepository`: User profile management and username availability checks.

---

## Verification

See `.agents/rules/operations.md` for verification commands and MCP tools.

---

## DOX Compliance

This is a binding DOX contract. Read before editing `baktaz_server/` paths.
Walk the DOX chain: root → child. Closer docs control local details.
Update this file when purpose, scope, or workflows change.
