# Serverpod Version Guide

Quick lookup by version with feature availability matrix.

---

## Major Version Comparison

| Feature | 1.x | 2.x | 3.0 | 3.3 | 3.4 | 4.0-beta |
|---------|-----|-----|-----|-----|-----|----------|
| **Web Server** | Built-in | Built-in | Relic | Relic | Relic | Relic |
| **Auth Module** | Legacy | Legacy | New (core, idp, bridge, migration) | + GitHub, Anonymous | + Facebook, Microsoft | + Account merging |
| **Polymorphism** | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Shared Models** | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| **IDPs** | Email | Email | Email, Google, Apple, Passkey | + GitHub, Anonymous | + Facebook, Microsoft | + Account merging |
| **Health Checks** | ❌ | ❌ | ❌ | `livez`/`readyz`/`startupz` | ✅ | ✅ |
| **CLI TUI** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ (`serverpod start`) |
| **Embedded PG** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Test Isolation** | ❌ | ❌ | ❌ | ❌ | ❌ | `withServerpod` |
| **`serverpod run`** | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Schema Hot Reload** | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| **PostGIS / pgvector** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **`httpOnly` Cookies** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ (beta.4) |

## IDP Availability Matrix

| Identity Provider | Version Added | Package |
|-------------------|---------------|---------|
| Email | 1.x | `serverpod_auth_idp_email` |
| Google | 3.0 | `serverpod_auth_idp_google` |
| Apple | 3.0 | `serverpod_auth_idp_apple` |
| Passkey | 3.0 | `serverpod_auth_idp_passkey` |
| GitHub | 3.3 | `serverpod_auth_idp_github` |
| Anonymous | 3.3 (experimental) | `serverpod_auth_idp_anonymous` |
| Facebook | 3.4 | `serverpod_auth_idp_facebook` |
| Microsoft | 3.4 | `serverpod_auth_idp_microsoft` |
| Firebase | 3.2 | `serverpod_auth_idp_firebase` |

## Auth Strategy Matrix

| Strategy | Version | Description |
|----------|---------|-------------|
| JWT | 3.0+ | Token-based, stateless |
| Server-Side Sessions | 3.0+ | Session-based, stateful |
| Legacy (pre-3.0) | 1.x-2.x | Removed in 3.0 |

## Key Model Features by Version

| Feature | Version |
|---------|---------|
| `uuid` field type | 1.x |
| `UuidValue` as `id` | 2.6 (exp), 4.0 stable |
| `Record` type | 2.5 |
| `immutable` keyword | 3.0 |
| `required` on nullable fields | 3.0 |
| `jsonKey` aliases | 3.3 |
| Enum properties | 3.3 |
| `extends`/`sealed` on Exception models | 4.0-beta.3 |
| `deferred`/`deferrable` relations | 4.0-beta.4 |
| `field=` keyword for FK columns | 4.0-beta.4 |
| `nulls_distinct` on unique indexes | 4.0-beta.2 (PostgreSQL) |
| `serial` on `int` columns | 4.0-beta.2 (PostgreSQL) |

## ORM Methods by Version

| Method | Version |
|--------|---------|
| `insert` | 1.x |
| `update` | 1.x |
| `updateWhere` | 3.0 |
| `updateById` | 3.0 |
| `upsert` | 1.x |
| `ignoreConflicts` on `insert` | 3.4 |
| `lockRows` / row-level locking | 3.4 |
| `noReturn` parameter | 4.0-beta.3 |
| `delete` returns removed objects | 2.0 |
| `orderDescending` (deprecated) | Removed in 4.0-beta.1 |

## CLI Commands by Version

| Command | Version |
|---------|---------|
| `serverpod start` | 1.x (experimental → 4.0 stable) |
| `serverpod generate` | 1.x |
| `serverpod create` | 1.x |
| `serverpod run` | 3.1 |
| `serverpod database start` | 4.0-beta.1 |
