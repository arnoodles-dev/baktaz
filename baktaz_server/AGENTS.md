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

Admin endpoints (`AdminEndpointBase`, `Scope.admin`): user management, blocking, scoping.
Auth endpoints: email/password, Google OAuth, Facebook OAuth, JWT refresh.
Account endpoints: profiles, addresses, contacts, wallets.

---

## Data Models

See `.spy.yaml` — account, address, contact, profile, wallet entities.

---

## Verification

See `.agents/rules/operations.md` for verification commands and MCP tools.

---

## DOX Compliance

This is a binding DOX contract. Read before editing `baktaz_server/` paths.
Walk the DOX chain: root → child. Closer docs control local details.
Update this file when purpose, scope, or workflows change.
