---
name: serverpod-sdk-changelog
description: >-
  Expert guide and lookup reference for the Serverpod SDK CHANGELOG, version history, breaking changes, and migrations from Serverpod 1.x through 4.x.
  Use this skill whenever the user asks about Serverpod version updates, breaking changes, upgrade paths,
  or needs guidance on Serverpod model definitions, endpoint patterns, authentication, and web server changes.
---

# Serverpod SDK Changelog & Version Guide (Serverpod 1.x to Modern 4.x)

This skill provides an authoritative, structured guide to Serverpod framework releases, module changes, API migrations, authentication system overhaul, and web server evolution sourced directly from the official [Serverpod CHANGELOG](https://github.com/serverpod/serverpod/blob/main/CHANGELOG.md).

---

## 🎯 Quick Reference: Major Version Milestones

| Version | Type | Key Highlights |
| :--- | :--- | :--- |
| **4.0.0-beta.x** | Major rewrite | Relic web server, new auth module, shared models, PostgreSQL 16, `serverpod start` TUI |
| **3.0.0** | Major | Auth overhaul (JWT, server-side sessions, IDPs), Relic web server, polymorphism |
| **2.0.0** | Major | `SerializableEntity` → `SerializableModel`, database result types, auth module split |
| **1.2.0** | Minor | Windows support, VS Code extension, LSP for model files |
| **1.0.0** | Stable | First stable release |

---

## ⚡ Fast Breaking Changes Matrix

| Breaking Change | Version | Migration |
| :--- | :--- | :--- |
| `context` → `request` in `Route.call`/`Route.handleCall` | 3.0.0 | Rename parameter in route methods |
| `SerializableEntity` → `SerializableModel` | 2.0.0 | Update base class reference |
| `enum` serialization `byIndex` → `byName` | 3.0.0 | Update model enums — no code change needed |
| `userIdentifier: Object` → `String` | 3.0.0 | Cast to String in auth calls |
| `AuthenticationInfo` auth callbacks → exceptions | 3.0.0 | Use try/catch pattern |
| `authenticationKeyManager` removed | 4.0.0-beta.2 | Remove parameter from client config |
| Legacy streaming APIs removed | 4.0.0-beta.2 | Use new streaming API |
| Legacy future call methods removed | 4.0.0-beta.2 | Use new type-safe `FutureCall` API |
| `ServerpodClientException` hierarchy refactored | 4.0.0-beta.4 | Use `ServerpodClientHttpException` for network errors |
| Empty migration `--force` flag removed | 3.0.0 | Use proper migration tags |
| `ignoreEndpoint` annotation removed | 4.0.0-beta.1 | Use `@doNotGenerate` (available since 2.7.0) |
| `orderDescending` parameter removed | 4.0.0-beta.1 | Use `sort` parameter on ORM methods |
| `SerializationManagerServer` removed | 4.0.0-beta.1 | Use built-in serialization |
| Web server widgets / legacy static directory classes removed | 4.0.0-beta.1 | Use `Relic` framework equivalents |
| Native Google Sign-In web removed (replaced by OAuth2) | 4.0.0-beta.1 | Use OAuth2 flow |

---

## 📚 Table of Contents & Reference Archive

| Document | Focus Area | Description |
| :--- | :--- | :--- |
| [`whats-new-in-serverpod-4-0.md`](references/whats-new-in-serverpod-4-0.md) | 4.0 changelog | Full 4.0.0-beta.0 through 4.0.0-beta.4 changelog with breaking changes |
| [`whats-new-in-serverpod-3-0.md`](references/whats-new-in-serverpod-3-0.md) | 3.0 changelog | Major 3.0 overhaul: auth module, Relic web server, polymorphism |
| [`serverpod-version-guide.md`](references/serverpod-version-guide.md) | Version guide | Quick lookup by version with feature availability matrix |
| [`upgrading-to-serverpod-4.md`](references/upgrading-to-serverpod-4.md) | Upgrade guide | Step-by-step migration from 3.x to 4.0 |

---

## 🛠️ Recommended Runbooks

### 1. Answering "What's New in Serverpod X"
1. Identify the requested version.
2. Read the corresponding reference document under `references/`.
3. Provide:
   - **Breaking changes** with migration instructions
   - **New features** grouped by module (core, auth, web, database)
   - **CLI changes** to `serverpod start`, `serverpod generate`, etc.

### 2. Upgrading Serverpod Versions
1. Read the [Upgrading to Serverpod 4.0](references/upgrading-to-serverpod-4.md) guide.
2. Update `pubspec.yaml` dependencies to target version.
3. Run `serverpod generate` to regenerate client code.
4. Fix deprecated API usage using the breaking changes matrix above.
5. Run tests to verify migration.

### 3. Understanding Authentication Changes
1. Serverpod 3.0+ uses new auth module (`serverpod_auth_core`, `serverpod_auth_idp`).
2. Identity providers: Email, Google, Apple, Passkey, GitHub, Anonymous, Facebook, Microsoft, Firebase.
3. Auth strategies: JWT, server-side sessions.
4. See [serverpod-auth skill](serverpod-auth) for implementation details.

### 4. Web Server Migration
1. Serverpod 3.0+ uses [Relic](https://pub.dev/packages/relic) instead of built-in web server.
2. Key concepts: dynamic routes, middleware, `WidgetRoute`, `FlutterRoute`, `SpaRoute`.
3. Serverpod 4.0 uses `Headers` class (from Relic) for header configuration.
4. See [serverpod-webserver skill](serverpod-webserver) for routing details.

---

## 🔧 Common Patterns by Version

### 4.0 Patterns
- `serverpod start` TUI with clickable URLs, structured Flutter logs
- `httpOnly` cookie authentication (opt-in, beta.4)
- `deferred`/`deferrable` relation flags for transaction constraint control
- `field=` keyword for explicit foreign key column generation
- `serverpod database start` for embedded PostgreSQL
- `withServerpod` test framework with complete isolation (beta.1+)

### 3.x Patterns
- `livez`/`readyz`/`startupz` health check endpoints (3.3+)
- `serverpod run` command for running scripts (3.1+)
- Shared models on shared packages (3.4+)
- `ignoreConflicts` on inserts (3.4+)
- `lockRows` / row-level locking (3.4+)
- PostGIS geography types support (3.5-beta+)

### 2.x Patterns
- `UuidValue` as model `id` type (2.6+ experimental, 4.0 stable)
- `@doNotGenerate` annotation replaces `@ignoreEndpoint` (2.7+)
- `serverpod generate` with `-d`/`--directory` flag (3.0+)
- `Record` type in models and streaming methods (2.5+)
