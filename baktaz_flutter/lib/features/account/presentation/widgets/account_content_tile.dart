import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/helpers/mappers/account_options_mapper.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class AccountContentTile extends StatelessWidget {
  const AccountContentTile({
    required this.title,
    required this.onTap,
    required this.optionKey,
    this.subtitle,
    this.actionWidget,
    super.key,
  });

  final String title;
  final String? subtitle;
  final AccountHeader optionKey;
  final Widget? actionWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      padding: Paddings.allSmall,
      child: Row(
        children: <Widget>[
          BaktazIcon(icon: getIt<AccountOptionsMapper>().getIcon(optionKey, title), color: context.colorScheme.primary),
          Gap.small(),
          Expanded(
            child: BaktazText(
              text: title.camelToSentence(),
              style: context.textTheme.bodyLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
