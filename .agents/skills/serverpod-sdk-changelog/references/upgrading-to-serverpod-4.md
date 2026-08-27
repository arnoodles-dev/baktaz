# Upgrading to Serverpod 4.0

Step-by-step migration guide from Serverpod 3.x to 4.0.

---

## Pre-Upgrade Checklist

- [ ] All dependencies in `pubspec.yaml` updated to `4.0.0-beta.3` (or later)
- [ ] `serverpod generate` run to regenerate client code
- [ ] Git stash or commit current work (upgrade is destructive in places)
- [ ] Database backup taken

---

## Step 1: Update Dependencies

Update all `serverpod_*` dependencies in `pubspec.yaml`:

```yaml
# Before (3.x)
dependencies:
  serverpod: ^3.4.0
  serverpod_client: ^3.4.0
  serverpod_auth_core_server: ^3.4.0
  serverpod_auth_idp_server: ^3.4.0
  serverpod_auth_server: ^3.4.0
  serverpod_flutter: ^3.4.0

# After (4.0)
dependencies:
  serverpod: 4.0.0-beta.3
  serverpod_client: 4.0.0-beta.3
  serverpod_auth_core_server: 4.0.0-beta.3
  serverpod_auth_idp_server: 4.0.0-beta.3
  serverpod_auth_server: 4.0.0-beta.3
  serverpod_flutter: 4.0.0-beta.3
```

**Note:** Serverpod 4.0 uses exact pinning (`4.0.0-beta.3`) rather than caret ranges.

---

## Step 2: Breaking Changes to Address

### 2.1 Remove `authenticationKeyManager` (beta.2)

Remove the `authenticationKeyManager` parameter from client configuration:

```dart
// Before
final client = ServerpodClient(...);
// authenticationKeyManager was a deprecated parameter — remove it

// After
final client = ServerpodClient(...);
```

### 2.2 Update Streaming API (beta.2)

Legacy streaming session and APIs have been removed. Ensure all streaming endpoints use the new streaming API.

### 2.3 Update Future Calls (beta.2)

Legacy future call methods have been removed. Use the new type-safe `FutureCall` API:

```dart
// Before (deprecated)
session.serverpod.futureCall FutureCallMyTask(session);

// After (4.0)
FutureCallMyTask.call(session);
```

### 2.4 Update Exception Handling (beta.4)

The `ServerpodClientException` hierarchy has been refactored:

```dart
// Before
catch (e) {
  if (e is ServerpodClientException) { ... }
}

// After
catch (e) {
  if (e is ServerpodClientHttpException) { ... } // Network/HTTP errors
}
```

### 2.5 Update ORM Methods (beta.1)

- Remove `orderDescending` parameter — use `sort` parameter instead
- Remove `ignoreEndpoint` annotation — use `@doNotGenerate` (available since 2.7.0)
- Remove `SerializationManagerServer` — use built-in serialization

### 2.6 Web Server Changes (beta.1)

- Remove deprecated web-server widgets — use `Relic` framework equivalents
- Remove legacy static directory classes
- Use `Relic` `Headers` class for header configuration (changed in 3.0)

### 2.7 Auth Changes (3.0, carried forward)

- `userIdentifier` parameter changed from `Object` to `String`
- `enum` serialization changed from `byIndex` to `byName`
- `context` parameter renamed to `request` in `Route.call` and `Route.handleCall`
- `SerializableEntity` → `SerializableModel` (if still using legacy)

---

## Step 3: Regenerate Code

```bash
serverpod generate
```

This regenerates all client code, type-safe endpoint methods, and serialization.

---

## Step 4: Update Authentication

If using the auth module (recommended for 3.0+):

```yaml
# generator.yaml
modules:
  serverpod_auth_core:
    nickname: auth_core
```

Ensure all auth-related configurations are updated for the 4.0 auth module.

---

## Step 5: Update Database Configuration

4.0 uses PostgreSQL 16:

```yaml
# In serverpod configuration
database:
  host: localhost
  port: 5432
  database: baktaz
```

If using Docker, the image has changed to `ghcr.io/serverpod/postgres:16`.

---

## Step 6: Run Tests

```bash
# Unit tests
dart test

# Integration tests (if applicable)
dart test test/integration/
```

---

## Step 7: Verify Health Checks

```bash
# Check server health endpoints
curl http://localhost:8080/livez
curl http://localhost:8080/readyz
curl http://localhost:8080/startupz
```

---

## Migration Version Path

```
3.0 → 3.1 → 3.2 → 3.3 → 3.4 → 4.0.0-beta.0 → beta.1 → beta.2 → beta.3
```

Each minor version may introduce additional breaking changes. Review the changelog for each intermediate version before jumping directly to 4.0.
