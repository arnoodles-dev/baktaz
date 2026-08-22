import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class BaktazRankTrend extends StatelessWidget {
  const BaktazRankTrend({required this.trend, super.key});

  final String trend;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = trend.startsWith('▲')
        ? Colors.green
        : trend.startsWith('▼')
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;

    return BaktazText(
      text: trend,
      style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
    );
  }
}
