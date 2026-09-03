import 'package:flutter/material.dart';

enum AccountHeader {
  accountMonetization(
    displayName: 'ACCOUNT & MONETIZATION',
    options: <String>['managePayment', 'healthSync'],
    icons: <IconData>[Icons.payment, Icons.favorite],
  ),
  preferencesSettings(
    displayName: 'PREFERENCES & SETTINGS',
    options: <String>['pushNotifications', 'language', 'darkMode'],
    icons: <IconData>[Icons.notifications, Icons.language, Icons.contrast],
  ),
  supportLegal(
    displayName: 'SUPPORT & LEGAL',
    options: <String>['helpCenter', 'shareFeedback', 'termsPrivacy', 'aboutUs'],
    icons: <IconData>[Icons.help, Icons.feedback, Icons.policy, Icons.info],
  );

  const AccountHeader({
    required this.displayName,
    required this.options,
    required this.icons,
  });

  final String displayName;
  final List<String> options;
  final List<IconData> icons;

  IconData iconForOption(String optionKey) {
    final int index = options.indexOf(optionKey);
    if (index >= 0 && index < icons.length) {
      return icons[index];
    }
    return Icons.help_outline;
  }

  static AccountHeader fromName(String name) {
    final AccountHeader? result =
        AccountHeader.values.where((AccountHeader h) => h.name == name).firstOrNull;
    if (result == null) {
      throw ArgumentError('Unknown AccountHeader name: $name');
    }
    return result;
  }
}
