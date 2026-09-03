import 'package:baktaz_shared/src/theme/baktaz_radius.dart';
import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// FilterChip — DESIGN.md §3.2
///
/// Chips scroll horizontally. Gap between chips: xs.
class BaktazFilterChip extends StatelessWidget {
  const BaktazFilterChip({required this.label, required this.isActive, this.onTap, super.key});

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BaktazRadius.pill,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.md, vertical: BaktazSpacing.xs),
          decoration: BoxDecoration(
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.surfaceContainer,
            borderRadius: BaktazRadius.pill,
          ),
          child: Center(
            child: BaktazText(
              text: label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
