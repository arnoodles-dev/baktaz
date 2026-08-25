# Admin Audit Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Fix Admin-specific audit violations: PopupMenuButton migration, magic numbers extraction.

**Tech Stack:** Flutter 3.47+, Material 3, AppSizes tokens.

**Spec:** See parent plan `2026-08-26-comprehensive-fix.md`.

---

### Task 4: PopupMenuButton → MenuAnchor (admin)

**Files:**
- Modify: `baktaz_admin/lib/features/remote_config/presentation/widgets/parameter_table.dart:165-220`

- [ ] **Step 1:** Replace `PopupMenuButton<SortCriteria>` with `MenuAnchor` + `_SortMenuItem` widget.
- [ ] **Step 2:** Analyze.
- [ ] **Step 3:** Commit.

```bash
git commit -m "refactor(admin): migrate PopupMenuButton to Material 3 MenuAnchor"
```
### Task 10: Admin magic numbers → named constants

**Files:**
- Modify: `baktaz_shared/lib/src/theme/app_sizes.dart`
- Modify: 6 admin widget files

- [ ] **Step 1-5:** Add tokens, swap call-sites, verify, commit.

```bash
git commit -m "fix(admin): extract magic dimensions into named constants"
```

---
