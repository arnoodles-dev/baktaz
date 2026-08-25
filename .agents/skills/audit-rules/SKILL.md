---
name: audit-rules
description: Audit monorepo compliance against .agents/rules/ contracts.
---

# Rule Audit Skill

Verify the codebase adheres to contracts in `.agents/rules/`.

## Scope & Load

1. Identify target package(s): `baktaz_server`, `baktaz_flutter`, `baktaz_admin`, `baktaz_shared`
2. Read applicable rules from `.agents/rules/`:
   - `code-quality.md`, `naming-convention.md`, `flutter-architecture.md`
   - `serverpod-architecture.md`, `state-management-architecture.md`
   - `error-handling-architecture.md`, `design-system.md`, `optimization.md`
   - `testing.md`, `operations.md`
3. Load reference docs if needed:
   - `error-handling-checklist.md`, `testing-advanced.md`, `flutter-feature-workflow.md`

## Execute

**Analysis tools:**
- `dart-mcp-server_analyze_files` — static analysis
- `dcm_dcm_analyze` — linting
- `codebase-memory-mcp_search_graph` — code discovery
- `codebase-memory-mcp_trace_path` — call graph tracing
- `serverpod` MCP — Serverpod-specific checks
- `rtk grep` — pattern search
- `git diff` — staged vs. committed changes

**Unused resources (do NOT use DCM):**
- `dart analyze` with unused lint rules
- `dart-mcp-server_analyze_files`
- `dcm_dcm_check_unused_files` (file-level only)

## Report Format

| Violation | File:Line | Rule | Fix |
|---|---|---|---|
| Description | `path:42` | `rule-name.md` | Specific action |

**Edge cases:**
- No violations → report "All checks passed"
- False positives → note as non-violation with reasoning
- Partial violations → separate by severity

## Completion

All rules loaded, all checks executed, violations logged in report format.
