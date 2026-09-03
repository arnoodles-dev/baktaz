import 'package:baktaz_shared/src/theme/baktaz_radius.dart';
import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// StatusBadge — DESIGN.md §1.5 / §2.4
///
/// Always combines background + icon + label. Never color alone.
/// Uses ColorScheme roles directly — no ThemeExtension for primary variants.
class BaktazStatusBadge extends StatelessWidget {
  const BaktazStatusBadge({required this.label, required this.variant, super.key});

  final String label;
  final StatusBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color textColor, IconData icon) = _resolveTokens(context);

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BaktazRadius.pill),
      padding: const EdgeInsets.symmetric(vertical: BaktazSpacing.xs2, horizontal: BaktazSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: BaktazSpacing.xs2),
          BaktazText(
            text: label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData) _resolveTokens(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return switch (variant) {
      StatusBadgeVariant.available => (scheme.secondaryContainer, scheme.onSecondaryContainer, Icons.verified),
      StatusBadgeVariant.confirmed => (scheme.secondaryContainer, scheme.onSecondaryContainer, Icons.check_circle),
      StatusBadgeVariant.active => (scheme.primaryContainer, scheme.onPrimaryContainer, Icons.refresh),
      StatusBadgeVariant.pending => (scheme.surfaceContainerHigh, scheme.onSurfaceVariant, Icons.access_time),
      StatusBadgeVariant.failed => (scheme.errorContainer, scheme.onErrorContainer, Icons.cancel),
      StatusBadgeVariant.neutral => (scheme.surfaceContainerHigh, scheme.onSurfaceVariant, Icons.pause),
    };
  }
}

enum StatusBadgeVariant { available, confirmed, active, pending, failed, neutral }
