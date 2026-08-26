# Admin Audit Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Fix Admin-specific audit violations: PopupMenuButton migration to Material 3 MenuAnchor, magic numbers extraction to AppSizes tokens.

**Tech Stack:** Flutter 3.47+, Material 3, AppSizes tokens.

**Spec:** See parent plan `2026-08-26-comprehensive-fix.md` for global constraints.

---

### Task 4: PopupMenuButton → MenuAnchor (admin)

**Files:**
- Modify: `baktaz_admin/lib/features/remote_config/presentation/widgets/parameter_table.dart:165-220`

**Interfaces:**
- Consumes: callback `void Function(SortCriteria)` named `onSortCriteriaSelected` (existing widget param), `sortCriteria` field, i18n keys `remote_config.table.sort_options|sort_alpha|sort_type|sort_date`.
- Produces: identical UX via Material 3 `MenuAnchor`; no public API change.

- [ ] **Step 1: Replace popup block**

Replace the whole `PopupMenuButton<SortCriteria>(...)` block (lines 165-220, ends at the closing `),` before `Gap.x2Small(),`) with:
```dart
        MenuAnchor(
          controller: menuController,
          style: const MenuStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: AppSizes.xSmall))),
          menuChildren: <Widget>[
            _SortMenuItem(
              icon: Icons.sort_by_alpha,
              label: context.i18n.remote_config.table.sort_alpha,
              selected: sortCriteria == SortCriteria.alphabetical,
              onTap: () {
                menuController.close();
                onSortCriteriaSelected(SortCriteria.alphabetical);
              },
            ),
            _SortMenuItem(
              icon: Icons.category_outlined,
              label: context.i18n.remote_config.table.sort_type,
              selected: sortCriteria == SortCriteria.type,
              onTap: () {
                menuController.close();
                onSortCriteriaSelected(SortCriteria.type);
              },
            ),
            _SortMenuItem(
              icon: Icons.date_range_outlined,
              label: context.i18n.remote_config.table.sort_date,
              selected: sortCriteria == SortCriteria.dateModified,
              onTap: () {
                menuController.close();
                onSortCriteriaSelected(SortCriteria.dateModified);
              },
            ),
          ],
          builder: (BuildContext context, MenuController controller, Widget? child) => IconButton(
            tooltip: context.i18n.remote_config.table.sort_options,
            padding: Paddings.allX2Small,
            constraints: const BoxConstraints(),
            onPressed: () => controller.open(),
            icon: BaktazIcon(
              icon: Either<String, IconData>.right(Icons.filter_list),
              size: AppSizes.iconSmall,
              color: AppColors.colorTextSecondary,
            ),
          ),
        ),
```
Obtain `menuController` in the enclosing State/Hook build: if class is HookWidget add `final MenuController menuController = useMemoized(MenuController.new);` near other hooks; if StatefulWidget add `final MenuController menuController = MenuController();` as a State field. Add imports: `package:flutter/material.dart` (present) — `MenuAnchor/MenuController/MenuItemButton/WidgetStatePropertyAll` ship in material; ensure `Paddings` imported from baktaz_shared (already used below at line 231).

Append private item widget at file bottom (before closing brace of library):
```dart
class _SortMenuItem extends StatelessWidget {
  const _SortMenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MenuItemButton(
    leadingIcon: BaktazIcon(
      icon: Either<String, IconData>.right(icon),
      size: AppSizes.iconSmall,
      color: selected ? AppColors.colorPrimary : AppColors.colorTextSecondary,
    ),
    onPressed: onTap,
    child: BaktazText(text: label),
  );
}
```
Delete the now-dead `PopupMenuItem` rows if analyzer flags anything.

- [ ] **Step 2: Analyze**

Run: `cd baktaz_admin && fvm dart analyze && dcm analyze 2>/dev/null || true`
(DCM is globally installed CLI at /opt/homebrew/bin/dcm, NOT a pub dependency — `fvm dart run dcm` fails. MCP preferred at review time.) Expected: no issues.

- Confirm `Either<String, IconData>.right(...)` usage is CORRECT as written (BaktazIcon API: left=SVG path, right=IconData; 75+ precedent call-sites). Only one PopupMenuButton exists (parameter_table.dart:165) — scope confirmed.

- [ ] **Step 3: Smoke via DTD (optional, server running)**

If a running app is connected: hot restart via dart MCP `hot_restart`, open Remote Config page, click filter icon — menu opens with 3 items, selection applies. If no live app, skip (analyze + suite gate suffices).

- [ ] **Step 4: Commit**

`git add -A && git commit -m "refactor(admin): migrate PopupMenuButton to Material 3 MenuAnchor"`


### Task 10: Admin magic numbers → named constants

**Files:**
- Modify: `baktaz_shared/lib/src/theme/app_sizes.dart` (append 5 tokens)
- Modify: `baktaz_admin/lib/features/dashboard/presentation/widgets/activities_overview_chart.dart:125`
- Modify: `baktaz_admin/lib/features/dashboard/presentation/widgets/activities_reports_chart.dart:71`
- Modify: `baktaz_admin/lib/features/content/presentation/widgets/content_table_header.dart:75`
- Modify: `baktaz_admin/lib/features/localization/presentation/widgets/dialogs/edit_translation_dialog.dart:46`
- Modify: `baktaz_admin/lib/features/localization/presentation/widgets/dialogs/add_translation_dialog.dart:26`
- Modify: `baktaz_admin/lib/features/remote_config/presentation/views/remote_config_screen.dart:307-317,433-439,477-483`

**Interfaces:** Produces `AppSizes.dialogWidth = 400`, `AppSizes.tableSearchWidth = 240`, `AppSizes.chartHeightLarge = 250`, `AppSizes.chartHeightMedium = 200`, `AppSizes.chartBarAreaHeight = 120`.

**Note on width-type values:** `dialogWidth` (400) and `tableSearchWidth` (240) get `ConstrainedBox(maxWidth:)` semantics at call sites — dialogs/search shrink on narrow viewports and cap on wide ones. Chart heights (`chartHeightLarge` 250, `chartHeightMedium` 200, `chartBarAreaHeight` 120) REMAIN FIXED tokens (chart proportions are designed; fluid heights = separate future plan with designer input + golden regen).

- [ ] **Step 1: Tokens** — append to `app_sizes.dart` after avatar block:
```dart
  // Component sizes — see DESIGN.md §component-sizes

  static const double dialogWidth = 400;
  static const double tableSearchWidth = 240;
  static const double chartHeightLarge = 250;
  static const double chartHeightMedium = 200;
  static const double chartBarAreaHeight = 120;
```
(Note: `chartBarAreaHeight` = 120 also added here; Task 6 in flutter plan already covers the HookWidget conversion but the token must exist in shared first.)

- [ ] **Step 2: Swap existing AppSizes** — each listed site:
  - `height: 250` → `height: AppSizes.chartHeightLarge`
  - `height: 200` → `AppSizes.chartHeightMedium`
  - `width: 400` → `ConstrainedBox(maxWidth: AppSizes.dialogWidth, child: ...)` (both dialogs)
  - `width: 240` → `ConstrainedBox(maxWidth: AppSizes.tableSearchWidth, child: ...)`
  - Ensure `baktaz_shared` import present.

- [ ] **Step 3: Shimmer skeletons** — `remote_config_screen.dart` lines 307-317, 433-439, 477-483. Replace:
  - `height: 16` → `AppSizes.medium`
  - `height: 12` → `AppSizes.small`
  - `width: 150` → file-local `static const double _shimmerTitleWidth = 150;`
  - `width: 120` → file-local `static const double _shimmerChipWidth = 120;`
  - `height: 14` → file-local `static const double _shimmerBarHeight = 14;`
  (No close AppSizes tokens exist for 14/120/150; use file-local for these.)

- [ ] **Step 4: Component Sizes section in DESIGN.md** — append to `baktaz_shared/DESIGN.md` (create if absent):
```markdown
## Component Sizes

| Token | Value | Usage |
|-------|-------|-------|
| `dialogWidth` | 400 | Max-width for auth/localization dialogs; applied via `ConstrainedBox(maxWidth:)` |
| `tableSearchWidth` | 240 | Max-width for table search field; applied via `ConstrainedBox(maxWidth:)` |
| `chartHeightLarge` | 250 | Fixed height for large dashboard charts (activities_overview_chart) |
| `chartHeightMedium` | 200 | Fixed height for medium dashboard charts (activities_reports_chart) |
| `chartBarAreaHeight` | 120 | Fixed height for chart bar area (HomeWeeklyStepsChart in flutter plan) |
```
Also update the comment in `app_sizes.dart` Step 1 above to point at the newly added section (already set to `see DESIGN.md §component-sizes`).

- [ ] **Step 5: Verify** — `cd baktaz_admin && fvm dart analyze && dcm analyze 2>/dev/null || true` → green.

- [ ] **Step 6: Commit** — `git commit -m "fix(admin): extract magic dimensions into named constants"`.

## Final Verification (all tasks done)

1. Monorepo analyze: `melos exec -- fvm dart analyze` OR per-package loop.
2. Suites: `make test_flutter`, `make test_admin`; `make test_server` only if Postgres up.
3. DCM re-audit: confirm cyclomatic-complexity >20 and number-of-parameters >5 lists are empty (using bare `dcm analyze`).
4. Three-tier grep gates:
   - ✅ **BLOCKING** (must be zero before merge):
     - `rtk grep -rn "CubitSignal<Map" baktaz_flutter/lib` → zero
     - `rtk grep -rn "LoginState\.failed\(|LoginStateFailed" baktaz_flutter/lib` → zero
     - Failure fields inside state classes (reviewer check)
     - `handleFailure` not called before any state emission on error paths (reviewer check)
   - ⚠️ **FIX-BEFORE-CLOSE** (non-blocking but tracked):
     - `rtk grep -rn "PopupMenuButton" baktaz_admin/lib` → zero
   - ℹ️ **INFORMATIONAL**:
     - `rtk grep -rn "lastFailure\|shouldReportToCrashlytics" .agents/` → zero
5. Update `.coverage_exclude` if new test utils appear; bump nothing else.

## Accepted Deviations (documented non-fixes)

- `auth_endpoint.completeRegistration` signature changes to `(Session, RegistrationForm)` — requires `serverpod generate` for client. Documented as required deviation.
- `connectivity_checker` instance-constructor (child/offlineMessage/2 callbacks) stays 4-param compliant; only static `scaffold` slimmed.
- Serverpod `return null` endpoints (NP1/NP2) — legitimate business absence per error-handling rules.
