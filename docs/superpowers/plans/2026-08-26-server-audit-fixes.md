# Server Audit Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Fix Server-specific audit violations: RegistrationForm model promotion, param count reduction.

**Tech Stack:** Serverpod 2.x, Dart, freezed.

**Spec:** See parent plan `2026-08-26-comprehensive-fix.md`.

---

### Task 7: Server param-count fixes (RegistrationForm model)

**Files:**
- Create: `baktaz_server/lib/src/features/auth/domain/models/registration_form.spy.yaml`
- Modify: `auth_endpoint.dart`, `i_auth_repository.dart`, `auth_repository.dart`, `auth_utils.dart`
- Run: `serverpod generate`

- [ ] **Step 1-9:** Create model, regenerate, update callers, verify, commit.

```bash
git commit -m "refactor(server): promote RegistrationForm to Serverpod model, fix param counts"
```

---

