import 'package:baktaz_flutter/features/account/domain/entity/model/user_rank.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

final class RankBadge extends StatelessWidget {
  const RankBadge({required this.rank, super.key});

  final UserRank rank;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: AppSizes.x2Small, horizontal: AppSizes.xSmall),
    decoration: BoxDecoration(
      color: rank.color.withValues(alpha: 0.15),
      borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.workspace_premium, size: 12, color: rank.color),
        const Gap(AppSizes.x2Small),
        BaktazText(
          text: rank.label,
          style: AppTextStyle.labelSmall.copyWith(color: rank.color, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
