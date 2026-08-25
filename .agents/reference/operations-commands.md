# Operations Commands Reference

[Extracted from operations.md — all Make targets, melos commands, and script listings]

## Make Targets

### Test Commands
- `make test_app` — baktaz_flutter
- `make test_admin` — baktaz_admin
- `make test_server` — baktaz_server
- `make test_shared` — baktaz_shared

### Project Setup
- `make init` — Initialize all tools (melos, serverpod, jaspr, flutter)
- `make clean` — Clean generated files and Flutter build

### Package Management
- `make pub_get` — Fetch dependencies
- `make pub_clean` — Clean pub cache

### Serverpod
- `make server_start` — Start server with `serverpod start --watch`
- `make server_apply_migrations` — Apply pending migrations
- `make server_seed` — Seed database
- `make server_gen` — Run build_runner + serverpod generate
- `make docker_run` — Start Docker services

## Melos Commands

### Package Setup
- `melos run setup:all` — Run setup for all packages (pub get + codegen)
- `melos run setup:app` — Setup baktaz_flutter
- `melos run setup:admin` — Setup baktaz_admin
- `melos run setup:server` — Setup baktaz_server
- `melos run setup:shared` — Setup baktaz_shared

### Code Generation
- `melos run slang` — Run localization generation
- `melos run build_runner` — Run freezed, injectable, chopper

### Dependency Management
- `melos run pub_get` — Fetch dependencies (ignores baktaz_client)
- `melos run pub_outdated` — Check outdated dependencies
- `melos run pub_upgrade` — Upgrade dependencies (--tighten)

### Formatting & Linting
- `melos run format` — Format all packages
- `melos run lint:all` — Run analyze with --fatal-infos
- `melos run fix_lint` — Auto-fix lint issues
- `melos run goldens` — Update golden tests

### Testing & Maintenance
- `melos run test` — Run tests for all packages (uses scripts/run_tests.sh)
- `melos run clean` — Clean Flutter builds

## Scripts Directory

Operational scripts live in `scripts/`:
- `run_tests.sh` — test runner with package selection
- `generate_lcov.sh` — coverage report generation
- `create_feature.sh` — scaffold new feature
- `create_feature_tests.sh` — scaffold feature tests
- `delete_generated_files.sh` — clean generated code
- `update_flutter_version.sh` — bump Flutter version
- `update_serverpod_version.sh` — bump Serverpod version
- `update_goldens_version.sh` — update golden test versions
