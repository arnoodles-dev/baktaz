---
trigger: glob
description: Serverpod backend structure, Session usage, DB migrations, API design, Service/Repository separation, and performance
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

---

## Service vs Repository

### Service
- Talks directly to an external (non-Serverpod) integration — third-party APIs, external SDKs, etc.
- Owns **how** — no business logic
- Examples: HitPay HTTP client, Chopper client, external SDK wrappers
- Located in: `data/service/`

### Repository
- Orchestrates services and can directly use database and other built-in Serverpod functionality (session, caching, etc.)
- Owns **what** — exposes clean API to endpoints/other repositories
- Examples: PaymentRepository, PayoutRepository, ChallengeRepository
- Located in: `data/repository/`

### Rule of Thumb
- If it's talking to something external to Serverpod, it's a **Service**
- If it's deciding what to do with that data — including querying the DB directly — it's a **Repository**
- Endpoints should only depend on **Repositories**, never Services

### Dependency Chain

```
Endpoint → Repository → Service → External (HTTP, SDK, Third-party API)
                  ↓
             Database (Session)
```

### Naming Convention
- Services: `<Name>Service` (e.g., `HitPayService`, `ChopperService`)
- Repositories: `<Name>Repository` (e.g., `PaymentRepository`, `PayoutRepository`)
- Repository interfaces: `I<Name>Repository` (e.g., `IPaymentRepository`)
- Located in: `domain/interface/` (interfaces), `data/repository/` (implementations), `data/service/` (services)
