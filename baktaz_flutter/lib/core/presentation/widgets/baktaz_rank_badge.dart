import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class BaktazRankBadge extends StatelessWidget {
  const BaktazRankBadge({required this.rank, super.key});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color badgeColor = switch (rank) {
      1 => const Color(0xFFFFD700), // Gold
      2 => const Color(0xFFC0C0C0), // Silver
      3 => const Color(0xFFCD7F32), // Bronze
      _ => theme.colorScheme.secondaryContainer,
    };
    final Color textColor = rank <= 3 ? Colors.black : theme.colorScheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: badgeColor, borderRadius: const BorderRadius.all(Radius.circular(6))),
      child: BaktazText(
        text: '#$rank',
        style: theme.textTheme.labelMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
