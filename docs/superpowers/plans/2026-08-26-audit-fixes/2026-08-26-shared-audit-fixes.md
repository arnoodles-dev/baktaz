# Shared Audit Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Fix Shared package violations: BaktazTextField complexity reduction.

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


## Final Verification

1. Monorepo analyze: `melos exec -- fvm dart analyze`
2. Suites: `make test_flutter`, `make test_admin`; text-field goldens included.
3. DCM re-audit: confirm cyclomatic-complexity >20 and number-of-parameters >5 lists are empty (using bare `dcm analyze`). Complexity drops 21 → ~17 (below threshold `cyclomatic-complexity: 20` in `baktaz_shared/analysis_options.yaml` lines 62-65; same thresholds across all four packages).
4. Three-tier grep gates:
   - ✅ **BLOCKING** (must be zero before merge):
     - `rtk grep -rn "CubitSignal<Map" baktaz_flutter/lib` → zero (indirect)
     - `rtk grep -rn "LoginState\.failed\(|LoginStateFailed" baktaz_flutter/lib` → zero (indirect)
   - ⚠️ **FIX-BEFORE-CLOSE** (non-blocking but tracked): none
   - ℹ️ **INFORMATIONAL**:
     - `rtk grep -rn "lastFailure|shouldReportToCrashlytics" .agents/` → zero
5. Update `.coverage_exclude` if new test utils appear; bump nothing else.

## Accepted Deviations

- **Full-fluid responsive chart heights** — deferred to separate plan requiring designer input + golden regen.
- **ErrorActions promotion to shared** — deferred; requires dep-inversion seam (DialogUtils/localization). Per-app drift is known debt: `baktaz_admin` lacks `onAuthenticationError`/`onRemoteConfigError`; validation handler differs.
