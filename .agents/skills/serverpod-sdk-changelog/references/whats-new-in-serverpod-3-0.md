# What's New in Serverpod 3.0

Major overhaul of authentication system and web server.

---

## 3.0.0

### Reworked web server
Serverpod 3 introduces a fully reworked web server with improved performance, additional features, and increased extensibility.
Built on top of the [Relic framework](https://pub.dev/packages/relic), it provides a more robust and flexible foundation for building web applications.

Key improvements include:
- Dynamic routes
- Middleware support
- Router fallbacks
- Comprehensive static asset handling, including cache busting and HTTP range requests

### New authentication module
A new authentication module has been developed based on the [authentication RFC](https://github.com/serverpod/serverpod/issues/3126). It provides a more flexible and robust foundation and significantly simplifies adding new identity providers.

Highlights:
- Multiple authentication strategies (JWT, server-side sessions)
- Multiple identity providers (Email, Google, Apple, Passkey) that can be configured and exposed independently
- New `AuthUser` class representing the authenticated user, their scopes, and all associated authentication tokens — extensible with custom user data
- Beautiful new UI components that provide a great user experience out of the box.
- Complete decoupling between UI and authentication logic on controllers that allow easy customization and replacement of the default components.

New packages:
- **`serverpod_auth_core`** — Core authentication logic and session management
- **`serverpod_auth_idp`** — Identity provider integrations (Email, Google, Apple, Passkey)
- **`serverpod_auth_bridge`** — Migration bridge for legacy auth (Email currently supported)
- **`serverpod_auth_migration`** — Tools and helpers for migrating auth data (Email currently supported)

### Polymorphism support
Serverpod now supports polymorphism on models and endpoints. This allows you to define a base class that can be extended by other classes using the `extends` keyword. The server will automatically handle the serialization and deserialization both to the database and in client server communication.

- feat: Adds support for receiving and returning polymorphic models on endpoints.
- feat: Removes the experimental flag on inheritance.
- feat: Generates abstract copyWith method to allow polymorphism on sealed models.
- feat: Adds support for inheritance on `id` field for table models for `serverOnly` models.
- fix: Handles unknown class names in polymorphic deserialization.

### Additional changes

#### Breaking changes
- feat: BREAKING. Removes support for creating empty migrations using the `--force` flag.
- feat: BREAKING. Use exit code `0` when no migrations are needed.
- feat: BREAKING. Changes default enum serialization from `byIndex` to `byName`.
- feat: BREAKING. Authenticated user id is now logged using a String to support multiple formats.
- fix: BREAKING. Uses the Relic `Headers` class for configuring headers in the Serverpod server.
- fix: BREAKING. Removes methods previously marked as deprecated.
- fix: BREAKING. Removes deprecated `SerializableEntity` class.
- fix: BREAKING. Changes the `userIdentifier` parameter in `AuthenticationInfo` from `Object` to `String`.
- refactor: BREAKING. Renames `context` parameter to `request` in `Route.call` and `Route.handleCall` methods.
- refactor(legacy auth): BREAKING. Replaces callbacks with exceptions and return object when validating password hash.

#### New features
- feat: Adds `FlutterRoute` and `SpaRoute` to simplify routing in single page applications.
- feat: Update template to include the new authentication module.
- feat: Adds parameter `values` to the `TemplateWidget` class.
- feat: Adds support for fetching `Request` from all session `Session` object through the `request` getter.
- feat: Adds support for resolving Dart doc template macros in client code generation.
- feat: Enable CLI commands to run from anywhere in a project directory.
- feat: Adds `-d` / `--directory` flag to the `serverpod generate` command.
- feat: Adds support for configuring server output modes in the test framework, defaults to logging only errors.
- feat: Adds support for endpoint inheritance in generated client code.
- feat: Adds support for generating abstract endpoint classes in client code.
- feat: Adds support for `immutable` keyword in models to generate immutable models.
- feat: Adds support for partial database updates with the `updateWhere` and `updateById` methods.
- feat: Adds support for `required` field keyword on nullable fields in model and exception definitions.
- feat: Adds support for `@unauthenticatedClientCall` annotation for endpoints.
- feat: Web server templates can now be placed in subdirectories.
- feat: Adds a `~` operator on expressions to perform `NOT` expression.
- feat: Server now stops automatically if the integrity check fails in `development` mode.
- feat: Introduces a new `authKeyProvider` interface to support multiple authentication key formats.

#### Fixes
- fix: Improves error message when there is a database mismatch on server startup.
- fix: Disables future call execution when none are registered.
- fix: Improves string representation for serializable exceptions.
- fix: Allows disabling features in the `generator.yaml` configuration file.
- fix: Fixes an issue on the deserialization engine that would prevent compilation on web in release mode.
- fix: Prevents the usage of non-constant defaults on immutable models.
- fix: Fixes missing inherited fields class constructor for table models with relation to inherited models.
