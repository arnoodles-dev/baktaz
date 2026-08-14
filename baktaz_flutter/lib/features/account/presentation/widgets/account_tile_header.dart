import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/widgets.dart';

class AccountTileHeader extends StatelessWidget {
  const AccountTileHeader({required this.header, super.key});

  final AccountHeader header;

  @override
  Widget build(BuildContext context) => BaktazText(
    text: header.name.camelToSentence(),
    style: context.textTheme.titleLarge?.copyWith(fontWeight: AppFontWeight.semiBold),
  );
}
