import 'package:baktaz_shared/src/theme/baktaz_radius.dart';
import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/theme/baktaz_type.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// StatSubCard — DESIGN.md §2.3
///
/// Inset sub-card displaying an uppercase eyebrow label over a bold metric value.
class StatSubCard extends StatelessWidget {
  const StatSubCard({
    required this.label,
    required this.value,
    this.isAccentValue = false,
    super.key,
  });

  final String label;
  final String value;
  final bool isAccentValue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BaktazRadius.chip,
      ),
      padding: const EdgeInsets.all(BaktazSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BaktazText(
            text: label.toUpperCase(),
            style: BaktazType.subheadingUppercase(scheme.onSurfaceVariant),
          ),
          const SizedBox(height: BaktazSpacing.xs2),
          BaktazText(
            text: value,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: isAccentValue ? scheme.primary : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
