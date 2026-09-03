import 'package:baktaz_flutter/features/account/domain/entity/model/user_rank.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

final class RankBadge extends StatelessWidget {
  const RankBadge({required this.rank, super.key});

  final UserRank rank;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: BaktazSpacing.xs2, horizontal: BaktazSpacing.xs),
    decoration: BoxDecoration(
      color: rank.color.withValues(alpha: 0.15),
      borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.workspace_premium, size: 12, color: rank.color),
        const Gap(BaktazSpacing.xs2),
        BaktazText(
          text: rank.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: rank.color, fontWeight: FontWeight.w600) ?? const TextStyle(),
        ),
      ],
    ),
  );
}
