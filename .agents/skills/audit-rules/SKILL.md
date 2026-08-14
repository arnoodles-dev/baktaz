---
name: audit-rules
description: Use when the user asks to audit the monorepo, verify rule compliance, or check if the codebase follows .agents/rules.
---

Run a **rule audit** to guarantee the monorepo adheres to the contracts in `.agents/rules/`.

## Steps

1. **Scope the target.** Identify which package (`<project>_flutter`, `<project>_server` / `*_flutter`, `*_server`, etc.) and which specific rule domains (e.g., naming, architecture) to inspect.
   - *Completion criterion:* Target paths and the required rule files from `.agents/rules/` are explicitly listed.

2. **Load the contracts.** Read the relevant `.md` files from `.agents/rules/`. Do not assume their contents.
   - *Completion criterion:* The text of every applicable rule is loaded into context.

3. **Execute the audit.** Analyze the target scope against the loaded contracts. Prefer agentic tools (`dart-mcp-server_analyze_files`, `dcm_dcm_analyze`, `search_graph`) for static analysis and architecture checks. **Explicitly check for unused resources** (widgets, imports, dependencies, assets, and dead code). **Do not use DCM for unused code scanning**, as detailed reports are gated behind a paid plan. Instead, use standard dart analyzer rules (e.g., `dart analyze` with unused lint rules enabled) or `dart-mcp-server_analyze_files`. You may still use `dcm_dcm_check_unused_files` for file-level unused checks.
   - *Completion criterion:* Every constraint from the loaded contracts is verified against the codebase, and all unused resources are identified, with any violations logged.

4. **Report.** Present a structured artifact detailing all violations, locations, and actionable fixes.
   - *Completion criterion:* The user receives a comprehensive report of the audit findings.

## External Reference

The source of truth for all checks lives in `.agents/rules/`:
- `ci-commands.md`
- `code-quality.md`
- `deepening-standards.md`
- `design-system.md`
- `flutter-architecture.md`
- `naming-convention.md`
- `optimization.md`
- `serverpod-architecture.md`
- `testing.md`

Point a **context pointer** to these files when running the audit for their respective domains.
