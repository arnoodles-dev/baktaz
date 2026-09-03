import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AccountOptionsMapper {
  AccountOptionsMapper();

  IconData getIcon(AccountHeader header, String title) => switch (header) {
    AccountHeader.accountMonetization => Icons.payment,
    AccountHeader.preferencesSettings => Icons.settings,
    AccountHeader.supportLegal => Icons.help,
  };
}
