# What's New in Serverpod 4.0

Full changelog for Serverpod 4.0.0-beta.0 through 4.0.0-beta.4.

---

## 4.0.0-beta.4

- feat: Allows overriding the default cache header for `StaticRoute` and `SpaRoute` from env vars.
- feat: Adds opt-in `httpOnly` cookie authentication for web clients.
- feat: Generates the column specified as `field=` on relations that require the explicit foreign key.
- feat: Introduces the `deferred` and `deferrable` flags on relations to postpone constraints evaluation inside transactions.
- feat: Makes `start` TUI app URLs clickable.
- fix: Restores inbound foreign keys on migrations when a table is recreated.
- fix: Resolves generated Dart formatters with captured stderr.
- fix: Fixes the `start` TUI app status on spontaneous exit.
- refactor: BREAKING. Refactors the `ServerpodClientException` hierarchy to introduce a proper exception for network errors. Previous HTTP-related exceptions now extend the sealed `ServerpodClientHttpException` class.
- refactor: BREAKING. Refactors the database exception hierarchy to throw specific exceptions for common operation errors (unique/foreign key constraint violations, SQLite database locked, etc.).
- chore: Generates stable import prefixes on generated code to reduce conflicts and diff noise.
- chore: Generates a simplified `Serverpod` class for cleaner initialization.
- chore: Reviews all skills for correctness and better guidance.

## 4.0.0-beta.3

- fix: Improves the `serverpod start` TUI borders and dividers with T-junction characters.
- fix: Fixes Google Sign-In accepting an access token minted for a different OAuth client that could be used to takeover an account. Backported to 3.4.12.
- fix: Fixes improper neutralization of string values in Serverpod's ORM that exposes SQL injection from user input. Backported to 3.4.12.
- fix: Includes session key salt in the session key hash. Backported to 3.4.12.
- fix: Makes the login rate limit bound guesses per user. Backported to 3.4.12.
- fix: Prevents rotating a refresh token for a blocked auth user. Backported to 3.4.12.
- chore: Ensures project build runs on a clean folder to avoid compilation issues.
- chore: Polishes and adds dark theme to the default Flutter app.

## 4.0.0-beta.2

- feat: BREAKING. Changes default message central delivery to global with fallback to local.
- feat: Honors the selected device on VS Code IDEs when launching the Flutter app from `serverpod start`.
- feat: Replaces the docker image for PostgreSQL by the official `ghcr.io/serverpod/postgres:16`.
- feat: Allows using `serial` on regular `int` columns on PostgreSQL.
- feat: Adds support for the `nulls_distinct` key on unique indexes on PostgreSQL.
- feat: Adds account merging mechanics to the auth module.
- feat: Allows overriding the default cache header for `FlutterRoute` from env vars.
- feat: Forwards shared package models through the owning module's server/client packages.
- fix: BREAKING. Removes dead email-related exceptions.
- fix: BREAKING. Removes the deprecated `authenticationKeyManager` client parameter.
- fix: BREAKING. Removes the legacy streaming session and deprecated streaming APIs.
- fix: BREAKING. Removes deprecated future call methods.
- fix: Fixes MCP server not being able to fetch logs when using `--no-tui`.
- fix: Makes shared-package logs visible in the CLI.
- fix: Exports WebSocket event types.
- fix: Prunes trailing empty migration dirs.
- fix: Makes generated Dart code `dart format` clean respecting the project options.
- fix: Makes `TermsAndPrivacyText` sign-in widget respond to app theming.
- fix: Keeps target schema fresh after hot reload.
- fix: Serves Flutter app config file on the correct path when project uses only webapp.
- fix: Generates `detach` and `detachRow` for named list relations without order dependence.
- fix: Updates language server state when model files change on disk.
- fix: Ensures client-side databases can be used on Flutter web apps.
- fix: Skips docker auto-start if using a remote Postgres host.
- chore: Avoid exposing unnecessary secrets on the template.
- chore: Improves the analytics reporting on used Serverpod features.

## 4.0.0-beta.1

- feat: Exposes flags on the `serverpod create` command to customize the created project.
- feat: Unifies and customizes social sign-in button styling.
- feat: Adds support for cache busting with dedicated syntax in templating system.
- feat: Allows running tests with complete isolation and plain `dart test` using `withServerpod`.
- feat: Uses custom embedded PostgreSQL binaries built with `pgvector` and `postgis` support.
- feat: Defaults to autostart docker on `serverpod start` if using PostgreSQL without `dataPath`.
- feat: Makes stack trace logs clickable to expand individually on `serverpod start` TUI.
- feat: Adds structured Flutter logs to `serverpod start` TUI.
- feat: Allows booting the embedded PostgreSQL from the CLI with `serverpod database start`.
- feat: Allows using the `table` keyword with `database: all` on shared package models.
- feat: Changes the `WidgetRoute.build` method to return `WebWidget?` and easily throw a 404.
- feat: Makes "X Stop App" / "X Close Tab" hints clickable in `serverpod start` TUI.
- feat: Removes the experimental flag from `serverpod start` command.
- fix: BREAKING. Removes the native Google Sign-In web implementation in favor of OAuth2.
- fix: BREAKING. Removes deprecated orderDescending parameter on ORM methods.
- fix: BREAKING. Removes deprecated `ignoreEndpoint` annotation from the CLI.
- fix: BREAKING. Removes deprecated `SerializationManagerServer` class.
- fix: BREAKING. Removes deprecated web-server widgets and legacy static directory classes.
- fix: Fixes VS Code debugger not working with the new `serverpod start` TUI.
- fix: Releases sessions from `MessageCentral` when streams are cancelled before session close.
- fix: Fixes generator failing when the client or shared package are imported on the server.
- fix: Invalidates corrupt cached server.dill after an interrupted compile.
- fix: Shows the device platform in the `serverpod start` TUI Flutter app status line.
- fix: Fixes `generate --watch` mode feedback loops when no changes existed.
- fix: Fixes high disk I/O when starting the Flutter app from `serverpod start`.
- fix: Allows unverified emails in Firebase IDP for default account validation.
- fix: Ensures any error is flushed to the terminal when exiting the TUI with a non-zero exit code.
- fix: Fixes Flutter app tabs not being marked as ready on non-web devices on the TUI.
- fix: Fixes the background of the `SignInWidget` and `EmailSignInWidget` not being transparent.

## 4.0.0-beta.0

- feat: Shows inline "Copied" confirmation in `serverpod start` TUI alerts.
- feat: Makes alert copy/dismiss clickable in `serverpod start` TUI.
- feat: Adds the `displayName` for Flutter app configs for a pretty tab title.
- feat: Adds support for creating server only projects.
- fix: Fixes `upsert` with `updateWhere` throwing on SQLite when conflicts are filtered out.
- fix: Adds missing export of `DeepCollectionEquality` for shared models. Backported to 3.4.11.
- fix: Prevents the creation of orphaned images on subsequent IDP logins. Backported to 3.4.11.
- refactor: Refines the serverpod start TUI app status, stop/close, and launcher.
- chore: Changes the template to serve the Flutter web app under root if website is not enabled.
