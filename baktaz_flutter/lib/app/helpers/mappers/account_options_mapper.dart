import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/my_account_option.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/settings_option.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/support_option.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AccountOptionsMapper {
  AccountOptionsMapper();

  Either<String, IconData> getIcon(AccountHeader header, String title) => switch (header) {
    AccountHeader.myAccount => _getMyAccountTitle(toMyAccountOption(title)),
    AccountHeader.support => _getSupportTitle(toSupportOption(title)),
    AccountHeader.settings => _getSettingsTitle(toSettingsOption(title)),
  };

  Either<String, IconData> _getMyAccountTitle(MyAccountOption option) => right(option.icon);

  Either<String, IconData> _getSupportTitle(SupportOption option) => right(option.icon);

  Either<String, IconData> _getSettingsTitle(SettingsOption option) => right(option.icon);

  MyAccountOption toMyAccountOption(String title) =>
      MyAccountOption.fromName(title) ?? (throw UnimplementedError('Invalid MyAccountOption title: $title'));

  SettingsOption toSettingsOption(String title) =>
      SettingsOption.fromName(title) ?? (throw UnimplementedError('Invalid SettingsOption title: $title'));

  SupportOption toSupportOption(String title) =>
      SupportOption.fromName(title) ?? (throw UnimplementedError('Invalid SupportOption title: $title'));
}
