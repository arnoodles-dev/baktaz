import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/helpers/mappers/account_options_mapper.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';

import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

final class AccountContentWidget extends StatelessWidget {
  const AccountContentWidget({
    required this.groupedOptions,
    required this.isStepsSyncActive,
    required this.onOptionsTap,
    super.key,
  });

  final Map<AccountHeader, List<String>> groupedOptions;
  final bool isStepsSyncActive;
  final void Function(String title) onOptionsTap;

  String _getSubtitle(BuildContext context, String optionKey) {
    final I18n$account$en account = context.i18n.account;
    return switch (optionKey) {
      'managePayment' => account.manage_payment_subtitle,
      'healthSync' => account.health_sync_subtitle,
      'pushNotifications' => account.push_notifications_subtitle,
      'language' => account.language_subtitle,
      'darkMode' => account.dark_mode_subtitle,
      'helpCenter' => account.help_center_subtitle,
      'shareFeedback' => account.share_feedback_subtitle,
      'termsPrivacy' => account.terms_privacy_subtitle,
      'aboutUs' => account.about_us_subtitle,
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: Paddings.horizontalMedium,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedOptions.entries.toList().asMap().entries.map<Widget>((
        MapEntry<int, MapEntry<AccountHeader, List<String>>> entry,
      ) {
        final int index = entry.key;
        final MapEntry<AccountHeader, List<String>> options = entry.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (index > 0) Gap.medium(),
            BaktazSectionHeader(
              title: options.key.displayName,
            ),
            Gap.medium(),
            ...options.value.asMap().entries.map<Widget>((
              MapEntry<int, String> optionEntry,
            ) {
              final int optionIndex = optionEntry.key;
              final String optionKey = optionEntry.value;
              final String subtitle = _getSubtitle(context, optionKey);
              final bool hasStatusBadge = optionKey == 'healthSync' && isStepsSyncActive;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (optionIndex > 0) Gap.small(),
                  BaktazListRow(
                    title: optionKey.camelToSentence(),
                    subtitle: subtitle.isNotEmpty ? subtitle : null,
                    leadingIcon: getIt<AccountOptionsMapper>().getIcon(options.key, optionKey),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => onOptionsTap(optionKey),
                  ),
                  if (hasStatusBadge) Gap.xSmall(),
                  if (hasStatusBadge)
                    const BaktazStatusBadge(
                      label: 'Active',
                      variant: StatusBadgeVariant.active,
                    ),
                ],
              );
            }),
          ],
        );
      }).toList(),
    ),
  );
}
