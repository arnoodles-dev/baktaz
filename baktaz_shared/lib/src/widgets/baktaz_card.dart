import 'package:baktaz_shared/src/theme/baktaz_elevation.dart';
import 'package:baktaz_shared/src/theme/baktaz_radius.dart';
import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_divider.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// StandardCard — DESIGN.md §3.1
///
/// The base card used throughout the app.
/// Slots: header row (icon + title + action) · divider · body · footer row.
final class BaktazCard extends StatelessWidget {
  const BaktazCard({required this.body, this.headerIcon, this.headerTitle, this.headerAction, this.footer, super.key});

  final Widget body;
  final IconData? headerIcon;
  final String? headerTitle;
  final Widget? headerAction;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasHeader = headerIcon != null || headerTitle != null || headerAction != null;
    final Widget? footer = this.footer;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BaktazRadius.card,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: BaktazElevation.surface(theme.brightness),
      ),
      padding: const EdgeInsets.all(BaktazSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (hasHeader) ...<Widget>[
            _CardHeader(icon: headerIcon, title: headerTitle, action: headerAction),
            const BaktazDivider(),
          ],
          body,
          if (footer != null) ...<Widget>[const BaktazDivider(), footer],
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({this.icon, this.title, this.action});

  final IconData? icon;
  final String? title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: BaktazSpacing.xs),
      child: Row(
        children: <Widget>[
          if (icon case final IconData effectiveIcon)
            Padding(
              padding: const EdgeInsets.only(right: BaktazSpacing.xs),
              child: Icon(effectiveIcon, size: BaktazSpacing.iconSmall, color: theme.colorScheme.primary),
            ),
          if (title case final String effectiveTitle)
            Expanded(
              child: BaktazText(
                text: effectiveTitle,
                style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
          if (action case final Widget effectiveAction) effectiveAction,
        ],
      ),
    );
  }
}
