---
trigger: glob
description: Backend structure, Session usage, DB migrations, API design, and performance rules
globs: *_server/lib/**, lib/**
---
# Serverpod Architecture

### Structure
- Layout: `lib/src/features/<feature>/`
- Layers: endpoint, domain, data.

### Session & DB
- **Session**: Pass `Session` everywhere.
- **Error handling**: Client exceptions in `.spy.yaml`; unexpected logged & rethrown. Use `session.log(msg, level:)` (no `print`). Remove stack traces/SQL from user output.
- **Database**: No raw SQL. Migrations only. API versioning required.
- **Performance**: DB indexing. Transactions for multi-writes.
- **PKs**: Prefer `UuidValue` over `int` for primary keys.
- **Timeouts & Config**: Set timeouts on DB queries and API calls. Centralize all configuration constants (timeouts, cache lifetimes, pagination limits, external URL base paths) under `lib/src/app/config/app_config.dart` using `AppConfig`. Do not use hardcoded duration or configuration literals.
- **Local cache**: Use `session.caches.local` for in-memory caching.
- **Idempotency**: Make critical endpoints idempotent.
- **Response types**: Always return typed domain models from endpoints, not raw `Map` or `dynamic`.
- **Backend validation**: Validate data integrity at endpoint boundaries before DB operations. Use Serverpod's built-in model validation where available; add manual checks for business rules not covered by schema constraints.

### Dependency Injection (DI)
- `@LazySingleton(as: Interface)`
- Uses `injectable` + `build_runner`.
