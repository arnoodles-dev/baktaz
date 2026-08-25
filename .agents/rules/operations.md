---
name: Operations & Project Management
trigger: always_on
description: Project setup, execution rules, codegen order, and operational guidelines across all packages
globs: **/*.dart,**/Makefile,scripts/**
---

# Operations & Project Management

## Git Workflow

- **Commit format**: `<type>: <description>` conventional commits
- **PR workflow**: Pre-PR checks before opening PR

## Commands Reference

Full Make, Melos, and script listings in `.agents/reference/operations-commands.md`.

Quick commands:
- `make test_*` — run package tests
- `melos run setup:all` — bootstrap all packages
- `make init` — initialize all tools

## Restricted Commands

Do NOT run these locally:
- `melos run test` — use `make test_*` instead
- `melos run lint:all` — use per-package lint
- `melos run format` — use per-package format

## Serverpod Execution

- User starts server with `serverpod start`. **NEVER start server yourself.** If server not running, stop and ask user to start.
- Use `serverpod` MCP for all server interaction:
  - `create_migration` / `apply_migrations` — database schema updates
  - `tail_server_logs` / `tail_flutter_logs` — read stdout/stderr
  - `hot_restart` — restart server isolate + connected Flutter apps
  - `get_flutter_app_dtd` — retrieve DTD URIs for driver debugging
  - `serverpod_hot_reload` — hot reload preserving state
  - `serverpod_spawn_flutter_app` — start Flutter app via MCP

## Codegen Order

Always run in this order:
1. `slang` — localization generation
2. `build_runner` — freezed, injectable, chopper
3. `serverpod generate` — Serverpod client + endpoints

## Verification Checklist

After code changes, run verification:
1. `dart analyze` — lint analysis
2. `dart format` — format modified files
3. `create_migration` + `apply_migrations` — if `.spy.yaml` models changed
4. `hot_restart` — if hot reload insufficient or Flutter reconnect needed
5. Run tests — `dart test` / `flutter test` per package
6. Verify logs — `tail_server_logs` / `tail_flutter_logs`

## Package Setup

SDK requirements: Dart `>=3.13.0`, Flutter `>=3.47.0`

Use `fvm` (Flutter Version Management) for version consistency:
- `fvm flutter pub get` — for Flutter packages
- `fvm dart pub get` — for Dart-only packages
- `fvm flutter test` — for Flutter test
- `fvm dart test` — for Dart test

## Scripts Directory

Operational scripts in `scripts/` — see `.agents/reference/operations-commands.md` for full listing.