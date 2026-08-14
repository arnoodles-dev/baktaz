# Monorepo Agent System

All agents are custom-defined as `.md` prompt files in this folder and registered in `opencode.json`.

1. **Primary agent** (`main`) — main orchestrator; selectable as active agent in OpenCode.
2. **Custom subagents** (`architect`, `developer`, `tester`, `reviewer`, `designer`, `writer`, `debugger`, `general`, `ask`) — spawnable only via Task tool; each overrides or extends named OpenCode mode with project-specific system prompt.

Topology is Orchestrator‑Worker design using `mode` enum (`primary` / `subagent`).

> **Config source of truth**: `opencode.json` at repo root registers all agents via `{file:.agents/agents/<name>.md}` prompt references. `.agents/agents/` is NOT auto-scanned — config file is authoritative.

## Agent Frontmatter Format

Each agent file is OpenCode‑native:

```yaml
---
description: When to use this agent
mode: primary          # primary | subagent | all
steps: 25              # max agentic iterations (replaces OpenCode temperature)
permission:             # agent-level permissions
  edit: allow
  bash: allow
  read: allow
  task: deny
---
System prompt for this agent.
```

- `mode: primary` = selectable as main agent (Main, Ask).
- `mode: subagent` = only spawnable via Task tool (all workers).
- `steps` caps agentic iterations; used in place of OpenCode’s `temperature`.
- Memory tools use agentmemory MCP: `agentmemory_memory_recall`, `agentmemory_memory_save`.

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                          USER TASK                               │
└─────────────────┬────────────────────────────┬───────────────────┘
                  │                            │
                  ▼                            ▼
┌───────────────────────────────┐  ┌─────────────────────────────────┐
│      MAIN (Orchestrator)    │  │       ASK (Clarifier)           │
│        mode: primary        │  │        mode: primary            │
│  edit:deny, bash:deny       │  │   edit:deny, bash:deny          │
│  task: all subagents        │  │   task:deny (questions only)    │
└──────────────┬──────────────┘  └─────────────────────────────────┘
               │
   ┌───────────┼────────────────────────┐
   │           │           │            │
   ▼           ▼           ▼            ▼
┌────────┐ ┌─────────┐ ┌────────┐  ┌────────┐
│DESIGNER│ │ARCHITECT│ │ WRITER │  │GENERAL │
│UI Plan │ │Architect│ │  Docs  │  │Cartogr.│
│sub     │ │sub     │ │sub     │  │sub     │
│edit:✓  │ │edit:✗  │ │edit:✓  │  │edit:✗  │
│bash:✗  │ │bash:✗  │ │bash:✗  │  │bash:✓  │
└────────┘ └────┬────┘ └────────┘  └────────┘
               │
               ▼
          ┌─────────┐
          │DEVELOPER│
          │Developer│
          │sub      │
          │edit:✓   │
          │bash:✓   │
          └────┬────┘
               │
        ┌──────┴──────┐
        ▼             ▼
   ┌─────────┐  ┌──────────┐
   │ TESTER  │  │ REVIEWER │
   │Test Eng.│  │ Reviewer │
   │sub      │  │sub       │
   │bash:✓   │  │edit:✓    │
   │edit:✓   │  │bash:✓    │
   └─────────┘  └──────────┘

               DEBUGGER (sub)
               Diagnosis
               edit:✓ bash:✓
               (spawned by Main on bug tasks)
```

## Agents

| Agent | Role | Mode | Key Permissions |
|-------|------|------|-----------------|
| **Main** | Full-Stack Orchestrator | primary | edit:deny, bash:deny, task: whitelist |
| **Ask** | Requirements Clarifier | **primary** | edit:deny, bash:deny, task:deny |
| **Architect** | Architect & Planner | subagent | edit:deny, bash:deny |
| **Developer** | Full-Stack Developer | subagent | edit:allow, bash:allow |
| **Tester** | Test Creation Specialist | subagent | edit:allow, bash:allow |
| **Reviewer** | Defensive Reviewer | subagent | edit:allow (tests), bash:allow |
| **Designer** | Visual Designer & UI Planner | subagent | edit:allow, bash:deny |
| **Writer** | Documentation Specialist | subagent | edit:allow, bash:deny |
| **Debugger** | Runtime Diagnosis | subagent | edit:allow, bash:allow |
| **General** | Codebase Cartographer | subagent | edit:allow, bash:allow |

## Rule Enforcement Flow

1. **Global Rules** – universal, win conflicts.
2. **Project AGENTS.md** – root `/AGENTS.md` contract.
3. **Child AGENTS.md** – per‑package contracts.
4. **`.agents/rules/`** – domain rules.
5. **Workspace Skills** – load on demand.

## Required Workspace Skills

Skills load on demand via `skill` tool. Every agent loads `pre-session-check` first.

| Agent | Skills |
|-------|--------|
| Main | pre-session-check, design-system, flutter-add-widget-preview, jaspr-fundamentals, security-review, documentation-lookup |
| Architect | pre-session-check, jaspr-fundamentals, jaspr-styling, flutter-apply-architecture-best-practices, design-system |
| Developer | pre-session-check, flutter-apply-architecture-best-practices, flutter-add-widget-preview, flutter-add-widget-test, flutter-add-integration-test, flutter-implement-json-serialization, flutter-setup-localization, jaspr-fundamentals, jaspr-styling, jaspr-js-interop, coding-standards |
| Tester | pre-session-check, flutter-add-widget-test, flutter-add-integration-test, coding-standards |
| Reviewer | pre-session-check, security-review, coding-standards, flutter-add-widget-test, jaspr-fundamentals, jaspr-pre-rendering-and-hydration, design-system |
| Designer | pre-session-check, design-system, flutter-add-widget-preview, jaspr-fundamentals, jaspr-styling, flutter-build-responsive-layout, frontend-design-direction |
| Writer | pre-session-check, documentation-lookup, coding-standards, design-system |
| Debugger | pre-session-check, dart-build-resolver, flutter-add-widget-test, coding-standards |
| General | pre-session-check |
| Ask | _(none — questions only)_ |

## MCP Tools Available

- `dart-mcp-server_*` – Dart/Flutter analysis, LSP, runtime errors  
- `dcm_dcm_*` – Dart metrics, formatting, unused code detection  
- `github-mcp-server_*` – GitHub PRs, issues, commits  
- `serverpod_*` – Serverpod docs & guides  
- `firebase-mcp-server_*` – Firebase ops (if used)

## Memory Protocol

### AgentMemory (Session/Team Memory)
- **BEFORE** code work: `agentmemory_memory_recall` for patterns.  
- **AFTER** work: `agentmemory_memory_save` to log lessons.  
- Tag with `#codebase`, `#[component-name]`, `#lessons-learned`.

### Codebase Memory (Structural Code Graph)
- **BEFORE** start: `search_graph` with natural language.  
- **WHEN** tracing deps: `trace_path` to expose call paths.  
- **WHEN** reading code: `get_code_snippet` for exact lines.  
- **WHEN** mapping project: `get_architecture` for overview.  
- **ALWAYS** prefer codebase‑memory‑mcp tools over grep/glob/read; fall back only for literals or config files.

## Routing Rules

All workers are custom subagents routed by Main.

| Task Type | Worker Chain |
|-----------|--------------|
| New feature (full-stack) | designer → architect → developer → tester → reviewer |
| New feature (UI only) | designer → developer → reviewer |
| Bug fix | debugger (repro/root cause) → architect (root cause spec) → developer (fix) → reviewer (regression test) |
| Code review request | reviewer directly |
| Architecture question | architect directly |
| Unknown codebase area | general first, then route |
| Ambiguous requirements | ask to clarify before routing |
| Codegen/migration only | developer directly |
| Design reference provided | designer first, then architect |
| Documentation update | writer directly |
| Quick fix (single file, obvious) | developer → tester → reviewer |

## Usage

### Switching to Main (Primary Agent)
Press **Tab** to cycle to Main or use configured `switch_agent` keybind.

### Invoking Workers Manually
Use `@` mentions:
```
@architect analyze the auth module
@developer implement the login screen
@reviewer review my changes
@designer create a blueprint for this design
@writer update the API docs
@debugger reproduce and diagnose a runtime crash
@general map an unfamiliar module
@ask clarify ambiguous requirements
```

### Via Main (Recommended)
Let Main orchestrate:
```
@main implement the user profile feature
```

## File Structure

```
.agents/
  agents/
    main.md          # Orchestrator (primary)
    ask.md           # Requirements Clarifier (primary)
    architect.md     # Architect & Planner (subagent)
    developer.md     # Full-Stack Developer (subagent)
    tester.md        # Test Creation Specialist (subagent)
    reviewer.md      # Defensive Reviewer (subagent)
    designer.md      # Visual Designer & UI Planner (subagent)
    writer.md        # Documentation Specialist (subagent)
    debugger.md      # Runtime Diagnosis (subagent)
    general.md       # Codebase Cartographer (subagent)
    README.md        # This file
  rules/             # Domain-specific rules
  skills/            # Workspace skills

opencode.json        # OpenCode config — registers all agents, permissions, and instructions
```

> **10 agents total**: 2 primaries (`main`, `ask`) + 8 subagents. All are custom `.md` prompt
> files referenced from `opencode.json` — no bare OpenCode built-ins used directly.
>
> `reviewer` is deliberately separate from `debugger`: Reviewer is adversarial code
> reviewer (quality, security, architecture); Debugger diagnoses runtime failures.
>
> `ask` is **primary** agent — user can invoke it directly to clarify requirements
> before Main begins orchestration, or Main can delegate to it mid-task.

## Token Efficiency

| Design Choice | Token Savings |
|---------------|---------------|
| Workers are leaf nodes (no `task`) | No sub-agent coordination overhead |
| Orchestrator read-only (edit deny) | Shorter prompt, no accidental file writes |
| Focused prompts per agent | No duplication across workers |
| Memory protocol on all agents | Avoids re-reading files, re-discovering patterns |
| `steps: 25` on precision workers | Bounded iterations, max precision for test assertions |
| Architect, general, ask read-only | No file write content in context |
| Skill loading on-demand | Only loads relevant skills, not all |## Context-Layer Tool Routing
- Code structure/impact -> `codebase-memory-mcp_*` tools.
- History/decisions -> `agentmemory_*` tools.
- Docs/PDFs/media -> `Graphify` commands (`/graphify .`).
- Domain onboarding -> NOT implemented (`Understand Anything` external).
  Fallback: `codebase-memory-mcp_get_architecture` + `read`.

## Tools
- `codebase-memory-mcp`: `codebase-memory-mcp_search_graph`, `codebase-memory-mcp_trace_path`, `codebase-memory-mcp_get_architecture`, etc.
- `agentmemory`: `agentmemory_memory_smart_search`, `agentmemory_memory_recall`, `agentmemory_memory_timeline`, etc.
- `Graphify`: `/graphify .`, `graphify export callflow-html`
- `Understand Anything` (External): `/understand`, `/understand-dashboard`
- Standard: `glob`, `grep`, `read`
