import 'package:baktaz_shared/src/theme/baktaz_type.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// RankBadge — DESIGN.md §2.4
///
/// Rank numeral using Space Grotesk italic typography.
class RankBadge extends StatelessWidget {
  const RankBadge({
    required this.rank,
    this.isCurrentUser = false,
    super.key,
  });

  final int rank;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String formattedRank = rank.toString().padLeft(2, '0');
    final Color color = isCurrentUser ? scheme.primary : scheme.onSurfaceVariant;

    return BaktazText(
      text: formattedRank,
      style: BaktazType.labelRanking(color),
    );
  }
}
