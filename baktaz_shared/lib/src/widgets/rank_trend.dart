// ignore_for_file: prefer-match-file-name

import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// RankTrend — DESIGN.md §2.5
///
/// Arrow + Text showing rank change trend.
enum RankTrendVariant { improved, dropped, unchanged }

class RankTrend extends StatelessWidget {
  const RankTrend({required this.change, this.variant, this.showValue = true, super.key});

  final int change;
  final RankTrendVariant? variant;
  final bool showValue;

  RankTrendVariant get _variant =>
      variant ??
      (change > 0
          ? RankTrendVariant.improved
          : change < 0
          ? RankTrendVariant.dropped
          : RankTrendVariant.unchanged);

  Color _getColor(ColorScheme scheme) => switch (_variant) {
    RankTrendVariant.improved => scheme.primary,
    RankTrendVariant.dropped => scheme.error,
    RankTrendVariant.unchanged => scheme.outline,
  };

  IconData _getIcon() => switch (_variant) {
    RankTrendVariant.improved => Icons.trending_up,
    RankTrendVariant.dropped => Icons.trending_down,
    RankTrendVariant.unchanged => Icons.remove,
  };

  String _getLabel() {
    if (!showValue) return '';
    final int absChange = change.abs();
    if (change > 0) return '+$absChange';
    if (change < 0) return '-$absChange';
    return '0';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color color = _getColor(scheme);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(_getIcon(), size: 16, color: color),
        if (showValue) ...<Widget>[
          const SizedBox(width: 4),
          BaktazText(
            text: _getLabel(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ],
    );
  }
}
