import 'package:baktaz_shared/src/theme/baktaz_radius.dart';
import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_avatar.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:baktaz_shared/src/widgets/rank_badge.dart';
import 'package:baktaz_shared/src/widgets/stake_return_value.dart';
import 'package:flutter/material.dart';

/// LeaderboardTable — DESIGN.md §2.8
///
/// Full leaderboard with infinite scroll.
class LeaderboardTable extends StatelessWidget {
  const LeaderboardTable({
    required this.entries,
    this.currentUserId,
    this.scrollController,
    this.onLoadMore,
    super.key,
  });

  final List<LeaderboardEntry> entries;
  final String? currentUserId;
  final ScrollController? scrollController;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 100 &&
            onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          final LeaderboardEntry entry = entries[index];
          final bool isCurrentUser = entry.userId == currentUserId;

          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: BaktazSpacing.md,
              vertical: BaktazSpacing.xs2,
            ),
            padding: const EdgeInsets.all(BaktazSpacing.sm),
            decoration: BoxDecoration(
              color: isCurrentUser ? scheme.primaryContainer : null,
              borderRadius: BaktazRadius.row,
              border: isCurrentUser
                  ? Border.all(color: scheme.primary, width: 1.5)
                  : null,
            ),
            child: Row(
              children: <Widget>[
                RankBadge(
                  rank: entry.rank,
                  isCurrentUser: isCurrentUser,
                ),
                const SizedBox(width: BaktazSpacing.sm),
                BaktazAvatar(
                  size: BaktazAvatar.sizeSM,
                  imageUrl: entry.imageUrl,
                  initials: entry.initials,
                ),
                const SizedBox(width: BaktazSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      BaktazText(
                        text: entry.name,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: scheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      BaktazText(
                        text: '${_formatNumber(entry.steps)} steps',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                StakeReturnValue(
                  value: _formatCurrency(entry.stakeReturn),
                  isPositive: entry.stakeReturn > 0,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  String _formatCurrency(double value) {
    if (value.abs() >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}k';
    }
    return '\$${value.toStringAsFixed(2)}';
  }
}

/// Data class for a leaderboard entry.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.rank,
    required this.name,
    required this.steps,
    required this.stakeReturn,
    this.imageUrl,
    this.initials,
  });

  final String userId;
  final int rank;
  final String name;
  final int steps;
  final double stakeReturn;
  final String? imageUrl;
  final String? initials;
}
