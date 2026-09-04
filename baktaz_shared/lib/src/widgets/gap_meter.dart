import 'package:baktaz_shared/src/theme/baktaz_radius.dart';
import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// GapMeter — DESIGN.md §2.6
///
/// Progress bar + Text showing gap to leader.
class GapMeter extends StatelessWidget {
  const GapMeter({
    required this.gap,
    required this.leaderValue,
    this.height = 8,
    super.key,
  });

  final int gap;
  final int leaderValue;
  final double height;

  bool get isLeading => gap <= 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    
    // If leading, show full bar. Otherwise show percentage of gap covered.
    final double progress = isLeading ? 1.0 : (gap / leaderValue).clamp(0.0, 1.0);
    final String label = isLeading ? 'Leading' : '+$gap steps';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: BaktazRadius.pill,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor: scheme.outlineVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              isLeading ? scheme.primaryContainer : scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: BaktazSpacing.xs2),
        BaktazText(
          text: label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isLeading ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
