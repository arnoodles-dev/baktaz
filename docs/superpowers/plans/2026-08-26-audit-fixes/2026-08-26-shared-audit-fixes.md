# Shared Audit Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Fix Shared package violations: BaktazTextField complexity reduction, AppSizes token extraction for chart dimensions.

**Tech Stack:** Flutter, flutter_hooks, Dart.

**Spec:** See parent plan `2026-08-26-comprehensive-fix.md` for global constraints.

---

### Task 8: BaktazTextField complexity (merge duplicate branches)

**Files:**
- Modify: `baktaz_shared/lib/src/widgets/baktaz_text_field.dart:116-215`

**Interfaces:** Public API untouched. Behavior preserved: `form`→TextFormField w/ validator; `email`/`normal`→TextField differing only in forced `TextInputType.emailAddress` for email.

- [ ] **Step 1: Merge email/normal switch arms** — replace the three `TextField`-producing arms with two:
```dart
        child: switch (textFieldType) {
          TextFieldType.password => _PasswordTextField(
            controller: controller,
            onChanged: onChanged,
            autofocus: autofocus,
            onSubmitted: onSubmitted,
            textInputAction: textInputAction,
            focusNode: effectiveFocusNode,
            hintText: hintText,
            labelText: labelText,
            inputDecoration: _getInputDecoration(context, style, isFocused: isFocused),
          ),
          TextFieldType.form => TextFormField(
            key: formFieldKey,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUnfocus,
            inputFormatters: inputFormatters,
            readOnly: readOnly || isDisabled,
            canRequestFocus: !(readOnly || isDisabled),
            controller: controller,
            focusNode: effectiveFocusNode,
            decoration: decoration ?? _getInputDecoration(context, style, isFocused: isFocused),
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: style,
            textAlign: textAlign,
            autofocus: autofocus,
            maxLength: maxLength,
            minLines: minLines,
            maxLines: maxLines,
            onChanged: onChanged,
            buildCounter: (_, {int? currentLength, int? maxLength, bool? isFocused}) => null,
          ),
          _ => TextField(
            key: formFieldKey,
            readOnly: readOnly || isDisabled,
            controller: controller,
            focusNode: effectiveFocusNode,
            decoration: decoration ?? _getInputDecoration(context, style, isFocused: isFocused),
            keyboardType: textFieldType == TextFieldType.email ? TextInputType.emailAddress : keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            canRequestFocus: !(readOnly || isDisabled),
            style: style,
            textAlign: textAlign,
            autofocus: autofocus,
            maxLength: maxLength,
            minLines: minLines,
            maxLines: maxLines,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            buildCounter: (_, {int? currentLength, int? maxLength, bool? isFocused}) => null,
          ),
        },
```
Complexity drops 21 → ~17 (one fewer case arm + ternary).

- [ ] **Step 2: Verify** — `cd baktaz_shared && fvm dart analyze` clean; `cd baktaz_flutter && fvm flutter test` green (text-field goldens included); `cd baktaz_admin && fvm flutter test` green.

- [ ] **Step 3: Commit** — `git commit -m "refactor(shared): collapse BaktazTextField duplicate TextField branches"`.




### Task 6: HomeWeeklyStepsChart → HookWidget + named chart constant

**Files:**
- Modify: `baktaz_shared/lib/src/theme/app_sizes.dart` (append token)
- Modify: `baktaz_flutter/lib/features/home/presentation/widgets/home_weekly_steps_chart.dart`
- Test: existing golden coverage for home widgets — run suite.

**Interfaces:** Produces `AppSizes.chartBarAreaHeight` (=120). Widget public API unchanged.

- [ ] **Step 1: Add token** to `app_sizes.dart` after `screenMarginH`:
```dart
  static const double chartBarAreaHeight = 120;
```

- [ ] **Step 2: Convert widget** — rewrite `home_weekly_steps_chart.dart`:
```dart
import 'package:baktaz_flutter/features/home/presentation/widgets/home_weekly_bar_item.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_weekly_chart_header.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_weekly_total_footer.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HomeWeeklyStepsChart extends HookWidget {
  const HomeWeeklyStepsChart({
    required this.weeklySteps,
    required this.averageSteps,
    required this.totalWeeklySteps,
    required this.goalTarget,
    super.key,
  });

  final List<int> weeklySteps;
  final int averageSteps;
  final int totalWeeklySteps;
  final int goalTarget;

  static const int _daysInWeek = 7;

  @override
  Widget build(BuildContext context) {
    const List<String> days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final ValueNotifier<int?> selectedIndex = useState<int?>(null);
    final List<int> safeSteps = weeklySteps.length == _daysInWeek ? weeklySteps : List<int>.filled(_daysInWeek, 0);

    return BaktazCard(
      body: Padding(
        padding: Paddings.allLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HomeWeeklyChartHeader(averageSteps: averageSteps),
            Gap.medium(),
            SizedBox(
              height: AppSizes.chartBarAreaHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List<Widget>.generate(
                  _daysInWeek,
                  (int index) => HomeWeeklyBarItem(
                    steps: safeSteps[index],
                    dayLabel: days[index],
                    goalTarget: goalTarget,
                    isSelected: selectedIndex.value == index,
                    onTap: () => selectedIndex.value = index,
                  ),
                ),
              ),
            ),
            Gap.medium(),
            HomeWeeklyTotalFooter(totalWeeklySteps: totalWeeklySteps),
          ],
        ),
      ),
    );
  }
}
```
(Also removes magic numbers 120 and 7.)

- [ ] **Step 3: Analyze + home goldens** — `cd baktaz_flutter && fvm dart analyze && fvm flutter test test/widget/features/home/ test/unit/` → green (goldens auto-refresh if pixel-shift).

- [ ] **Step 4: Commit** — `git commit -m "refactor(flutter): HomeWeeklyStepsChart to HookWidget, extract chart height token"`.

