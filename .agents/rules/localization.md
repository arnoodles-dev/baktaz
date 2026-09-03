---
trigger: glob
description: Slang localization conventions, i18n JSON structure, AppLocalizationCubit state, and UI text access patterns
globs: baktaz_flutter/lib/**, baktaz_admin/lib/**, baktaz_flutter/assets/i18n/**, baktaz_admin/assets/i18n/**
---

# Localization

## Scope & Package Applicability

Localization is powered by Slang (`slang_build_runner:legacy`).

- **Applicable Packages**: `baktaz_flutter` and `baktaz_admin` must use Slang localization for all user-facing text.
- **Exempt Packages**: `baktaz_server` is exempt (server messages, logs, and error responses use fixed string literals or error codes).
- **Shared Library (`baktaz_shared`)**: Reusable UI components receive localized strings as widget arguments/props from calling screens and must not access localization directly.

## File Location & Naming

- Translation files live at `assets/i18n/<locale>.i18n.json`.
- Primary file name: `en.i18n.json` (English is the base locale).
- Additional locales follow ISO language/country codes (e.g., `es.i18n.json`, `fr.i18n.json`).

## JSON Key Hierarchy & Formatting

- **Key Style**: All keys must use `snake_case`.
- **Feature Namespacing**: Organize keys into nested feature namespaces (e.g., `common`, `auth`, `login`, `account`, `home`, `dashboard`).
- **Common Keys**: Reusable labels, button titles, dialog actions, and shared error messages live under the `common` block (e.g., `common.cancel`, `common.save`, `common.error.generic`).
- **Typed Arguments**: Use Slang placeholder syntax with explicit types (e.g., `"version_text": "Version ${version: String}"`, `"item_count": "${count: int} items"`).
- **Rich Text / HTML Tags**: Use HTML tags for inline styling or links (e.g., `"terms_notice": "By continuing, you agree to our <link href=\"${termsUrl: String}\">Terms of Service</link>"`).

## UI Presentation Access & Reactivity

- **Context Access**: UI widgets must access translations exclusively via `context.i18n` (provided by `BuildContextExt`).
- **Forbidden**: Direct `I18n` class instantiation or direct file calls in UI components are strictly forbidden.
- **State Management**: App locale state is managed by `AppLocalizationCubit` (extending `CubitSignal<I18n>`).
- **Non-Widget Access**: Logic outside the widget tree (e.g., background handlers, notification utilities) retrieves current translations via `getIt<AppLocalizationCubit>().stateValue`.
- **Dynamic Overrides**: Dynamic runtime string replacements or server-driven translation overrides must go through `SlangOverrideHelper`.

## Slang Generator Config & Codegen

- Generator package: `slang_build_runner:legacy`.
- Output path: `lib/app/generated/localization.g.dart`.
- Root translation class name: `I18n`.
- Generator setting: `translation_overrides: true`.
- **Rule**: Never manually edit `localization.g.dart`. Re-run codegen via `make generate` or `dart run build_runner build` after updating any `*.i18n.json` file.

## Strict Rule Enforcement

- **ZERO hardcoded user-facing strings** in `baktaz_flutter` and `baktaz_admin`.
- All user-facing titles, labels, error messages, placeholders, and tooltips must reference `context.i18n.*`.
