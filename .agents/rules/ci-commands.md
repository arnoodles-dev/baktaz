---
trigger: glob
description: CI pipeline steps, melos commands, serverpod scripts, and pre-PR checks
globs: **/*.dart,**/Makefile
---
# CI & Git Commands

### Development & Git Workflow
- **Commit format**: `<type>: <description>` conventional commits.
- **PR workflow**: Pre-PR checks before opening PR.

### Verification
- **Localized test commands**: 
  - `make test_app`
  - `make test_admin`
  - `make test_server`
  - `make test_shared`
  - `make test_site`
- **Restricted global commands**: No `melos run test`, `melos run lint:all`, or `melos run format` locally. Run inside package/target instead.
- **Codegen order**: `slang` → `build_runner` → `serverpod generate`.
