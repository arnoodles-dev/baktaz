import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/user_rank.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/rank_badge.dart';
import 'package:baktaz_shared/baktaz_shared.dart' hide RankBadge;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AccountHeaderCard extends StatelessWidget {
  const AccountHeaderCard({
    required this.fullName,
    required this.username,
    required this.memberSince,
    required this.imageUrl,
    required this.onEditProfile,
    this.isLoading = false,
    this.rank,
    super.key,
  });

  final String? fullName;
  final String? username;
  final DateTime? memberSince;
  final String? imageUrl;
  final VoidCallback onEditProfile;
  final bool isLoading;
  final UserRank? rank;

  @override
  Widget build(BuildContext context) => Skeletonizer(
        enabled: isLoading,
        child: Padding(
          padding: Paddings.screenMarginH,
          child: BaktazCard(
            headerTitle: fullName,
            headerIcon: Icons.person,
            headerAction: BaktazButton(
              text: context.i18n.account.account_header_card.edit_profile,
              onPressed: onEditProfile,
              buttonType: ButtonType.outlined,
              isEnabled: !isLoading,
            ),
            body: Padding(
              padding: Paddings.verticalMedium,
              child: Row(
                children: <Widget>[
                  BaktazAvatar(
                    size: BaktazAvatar.sizeLG,
                    imageUrl: imageUrl,
                    initials: AccountHeaderCard.initialsFromFullName(fullName),
                  ),
                  Gap.large(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        BaktazText(
                          text: username ?? '',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap.x2Small(),
                        BaktazText(
                          text: memberSince != null
                              ? context.i18n.account.account_header_card.member_since(
                                  date: DateFormat.yMMM().format(memberSince!),
                                )
                              : '',
                          style: context.textTheme.bodySmall,
                        ),
                        if (rank != null) ...<Widget>[
                          Gap.x2Small(),
                          RankBadge(rank: rank!),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  static String? initialsFromFullName(String? name) {
    if (name == null || name.isEmpty) return null;
    final List<String> parts = name.split(' ');
    return parts.length == 1
        ? parts.first.characters.getRange(0, 1).toString().toUpperCase()
        : '${parts.first.characters.getRange(0, 1)}${parts.last.characters.getRange(0, 1)}'
            .toUpperCase();
  }
}
