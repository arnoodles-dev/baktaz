import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/theme/baktaz_type.dart';
import 'package:baktaz_shared/src/widgets/baktaz_avatar.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// LeadersStrip — DESIGN.md §2.4
///
/// Row showing top 3 participants with avatars and podium rank.
class LeadersStrip extends StatelessWidget {
  const LeadersStrip({
    required this.participants,
    super.key,
  });

  final List<LeaderParticipant> participants;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<LeaderParticipant> displayParticipants = participants.take(3).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(displayParticipants.length, (int i) {
        final LeaderParticipant participant = displayParticipants[i];
        final int rank = i + 1;
        final Color rankColor = rank == 1 ? scheme.primary : scheme.onSurfaceVariant;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BaktazAvatar(
                size: BaktazAvatar.sizeSM, // 36dp
                imageUrl: participant.imageUrl,
                initials: participant.initials,
              ),
              const SizedBox(height: BaktazSpacing.xs2),
              BaktazText(
                text: participant.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              BaktazText(
                text: rank.toString().padLeft(2, '0'),
                style: BaktazType.labelRanking(rankColor),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Data class for a leaderboard participant.
class LeaderParticipant {
  const LeaderParticipant({
    required this.name,
    this.imageUrl,
    this.initials,
  });

  final String name;
  final String? imageUrl;
  final String? initials;
}
