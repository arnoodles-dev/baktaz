---
name: pre-session-check
description: >
  Mandatory pre-session initialization workflow. Validates tooling, enforces rule hierarchy,
  loads SDK changelogs, and prepares agent for deterministic execution.
  **MANDATORY**: Run at session start before any task execution.
  Use when user says "pre-flight", "check tools", "validate session", "are tools up", or "/pre-session-check".
user-invocable: true
---

# Pre-Session Check

Mandatory initialization workflow before any development task.

## Quick Start

```text
/pre-session-check
```

## Phase 1: Tool Validation (~60 seconds)

Verify all core tools are operational:

| Tool | Command | Recovery if Failed |
|---|---|---|
| AgentMemory | `agentmemory_memory_smart_search` test query | `agentmemory_memory_diagnose`, `agentmemory_memory_heal` |
| Codebase Memory | `codebase-memory-mcp search_graph` test query | `codebase-memory-mcp_index_repository` |
| Graphify | `graphify query "<question>"` | `graphify update .` |
| MCP Servers | `dart-mcp-server_*`, `serverpod_*`, etc. | Check server status, restart if needed |

> **Verification note:** Check Graphify by running `graphify query "<question>"` — do NOT use `glob` for `graphify-out/graph.json`. The glob pattern may fail on relative path resolution even when the graph exists and is queryable. If `graphify query` returns nodes, Graphify is operational regardless of whether `graphify-out/graph.json` appears in glob results.


### Known Issues

| Feature | Status | Details |
|---------|--------|---------|
| Memory Slots | ⛔ Disabled | Bug in MCP bridge — slot tools crash when `AGENTMEMORY_SLOTS` is off. Pending fix: [PR #894](https://github.com/rohitg00/agentmemory/pull/894). Enable after merge. |

## Phase 2: SDK Changelog Retrieval

Fetch latest Dart and Flutter updates, breaking changes, and API changes:

```bash
# Load Dart SDK changelog
skill dart-sdk-changelog

# Load Flutter SDK changelog  
skill flutter-sdk-changelog
```

**Purpose:** Avoid using deprecated APIs, know breaking changes, leverage new features.

## Phase 3: Rule Hierarchy Enforcement

**MANDATORY precedence order:**

1. **Global rules** (`~/.config/opencode/AGENTS.md`) — highest priority, universal
2. **Project contract** (`AGENTS.md`) — project-wide invariants
3. **Child contracts** (`baktaz_*/AGENTS.md`) — package-specific rules
4. **Domain rules** (`.agents/rules/*.md`) — functional area constraints
5. **Skills** (`.agents/skills/*.md`) — on-demand capabilities
6. **Session context** — current task requirements

**Rule:** No child may weaken parent. Closer docs control local details.

## Phase 4: Skill Utilization Mandate

**Before using generic approaches, check `.agents/skills/`:**

| Task Type | Required Skill |
|---|---|
| Flutter architecture | `flutter-apply-architecture-best-practices` |
| Error handling | `bloc-signals` |
| Security review | `security-review` |
| Design system | `design-system` |
| Documentation | `documentation-lookup` |
| Debugging | `dart-build-resolver` |
| Testing | `flutter-add-widget-test`, `flutter-add-integration-test` |

**Rule:** If a skill exists for the task, use it. Do not implement generic solution.

**Scripting Preference:** When creating temporary scripts (migration helpers, codegen tools, data transforms), prefer Dart over Python. Use `dart run` or write a Dart script. Python only when no Dart equivalent exists (Firebase CLI, ML pipelines).

## Phase 5: Sub-Agent Delegation

**Actively leverage sub-agents from `.agents/agents/`:**

| Task Type | Delegate To |
|---|---|
| Planning/specs | `@architect` |
| Implementation | `@developer` |
| Testing | `@tester` |
| Review | `@reviewer` |
| Documentation | `@writer` |
| UI design | `@designer` |
| Bug diagnosis | `@debugger` |
| Exploration | `@general` |
| Clarification | `@ask` |

**Rule:** Do not implement directly if a specialized agent exists. Delegate and synthesize.

## Phase 6: Governance File Verification

Confirm these files are readable:
- [ ] `AGENTS.md` (root project contract)
- [ ] `.agents/rules/*.md` (domain rules)
- [ ] `.agents/skills/*.md` (available skills)
- [ ] `DESIGN.md` (design tokens)
- [ ] Child `AGENTS.md` files (package contracts)

## Phase 7: Acknowledgment & Commitment (MANDATORY)

**After passing all checks, the agent MUST explicitly acknowledge and commit:**

### Required Acknowledgment Statement

```markdown
## Pre-Session Commitment

I, [agent name], acknowledge that:

1. **Tools validated**: All required tools (AgentMemory, Codebase Memory, Graphify, MCP servers) are operational.
2. **SDK changelogs loaded**: I will use latest Dart/Flutter knowledge and avoid deprecated APIs.
3. **Rule hierarchy confirmed**: I understand and will enforce: Global -> Project -> Child -> Domain -> Skills -> Session.
4. **Skills prioritized**: I will use `.agents/skills/` before generic approaches.
5. **Delegation active**: I will delegate to specialized sub-agents (`@architect`, `@developer`, etc.) before implementing directly.
6. **Governance files read**: I have read and will comply with all AGENTS.md and `.agents/rules/` files.
7. **DOX compliance**: I will walk the DOX chain before editing and update affected docs after.
8. **Scripting preference**: I will use Dart for scripting unless Python is the only viable option.
```

### Commitment Actions

After acknowledgment, the agent MUST:

1. **State compliance** — Explicitly confirm each check passed
2. **List applicable rules** — Enumerate rules relevant to current task
3. **Identify delegation targets** — List sub-agents that will be used
4. **Note skill dependencies** — List skills to load during task
5. **Confirm ready** — Only then proceed to task execution

**If any check fails, report blockers and DO NOT proceed until resolved.**

## Failure Handling

| Issue | Symptom | Recovery |
|---|---|---|
| Tool unavailable | MCP error or empty response | Check server status, restart |
| Rules unreadable | File not found | Verify `.agents/` directory exists |
| Skill missing | No matching skill | Fall back to generic approach, note gap |
| Agent unavailable | Task spawn failed | Check opencode.json registration |

## Output Format

```markdown
## Pre-Session Check Results

| Check | Status | Notes |
|-------|--------|-------|
| AgentMemory | ✅/❌ | |
| Codebase Memory | ✅/❌ | |
| Graphify | ✅/❌ | |
| MCP Servers | ✅/❌ | |
| Memory Slots | ⏳ Pending | PR #894 — do not enable |

### Rules Loaded
- [x] Global AGENTS.md
- [x] Project AGENTS.md
- [x] Child contracts
- [x] Domain rules

### Status
- ✅ Ready — proceed to task
- ❌ Blocked — report blockers
```
