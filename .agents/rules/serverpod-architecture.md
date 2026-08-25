---
trigger: glob
description: Serverpod backend structure, Session usage, DB migrations, API design, and performance
globs: *_server/lib/**, lib/**
---

# Serverpod Architecture

## Structure

- Layout: `lib/src/features/<feature>/`
- Layers: endpoint, domain, data

## Session & DB

- **Session**: Pass `Session` everywhere
- **Error handling**: See `error-handling-architecture.md` — client exceptions in `.spy.yaml`, logged via `session.log()`
- **Database**: No raw SQL. Migrations only.
- **PKs**: Prefer `UuidValue` over `int`
- **Timeouts & Config**: Set on DB queries and API calls. Centralize in `lib/src/app/config/app_config.dart`
- **Local cache**: `session.caches.local`
- **Idempotency**: Make critical endpoints idempotent
- **Response types**: Always return typed domain models, not `Map` or `dynamic`

## Backend Validation

Validate at endpoint boundaries before DB operations. Use Serverpod's built-in validation; add manual checks for business rules.

## DI

`@LazySingleton(as: Interface)` with `injectable` + `build_runner`.

## Performance

- DB indexing
- Transactions for multi-write operations
- See optimization.md for server performance rules

## API Versioning

Required for breaking changes.