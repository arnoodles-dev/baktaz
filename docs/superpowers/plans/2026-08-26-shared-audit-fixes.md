# Shared Audit Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Fix Shared package violations: BaktazTextField complexity reduction, AppSizes token extraction.

**Tech Stack:** Flutter, bloc_signals, Dart.

**Spec:** See parent plan `2026-08-26-comprehensive-fix.md`.

---

### Task 6: HomeWeeklyStepsChart → HookWidget

**Files:**
- Modify: `baktaz_shared/lib/src/theme/app_sizes.dart`
- Modify: `home_weekly_steps_chart.dart`

- [ ] **Step 1:** Add `AppSizes.chartBarAreaHeight = 120`.
- [ ] **Step 2:** Convert to HookWidget with `useState<int?>(null)`.
- [ ] **Step 3-4:** Verify, commit.

```bash
git commit -m "refactor(flutter): HomeWeeklyStepsChart to HookWidget, extract chart height token"
```

---

### Task 8: BaktazTextField complexity (merge duplicate branches)

**Files:**
- Modify: `baktaz_shared/lib/src/widgets/baktaz_text_field.dart:116-215`

- [ ] **Step 1-3:** Merge email/normal arms, verify, commit.

```bash
git commit -m "refactor(shared): collapse BaktazTextField duplicate TextField branches"
```

---

