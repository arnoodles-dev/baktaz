import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// SlotsProgressRing — DESIGN.md §1.10
///
/// Circular progress showing filled/total slots (e.g., "18/25").
/// Track: outlineVariant, fill: primary.
class BaktazSlotsProgressRing extends StatelessWidget {
  const BaktazSlotsProgressRing({
    required this.filled,
    required this.total,
    this.size = 64,
    this.strokeWidth = 6,
    super.key,
  });

  final int filled;
  final int total;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    
    final double progress = total > 0 ? (filled / total).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: scheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
          BaktazText(
            text: '$filled/$total',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
