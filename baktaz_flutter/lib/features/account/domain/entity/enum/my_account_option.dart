import 'package:flutter/material.dart';

enum MyAccountOption {
  profile(displayName: 'Profile', icon: Icons.person),
  preferences(displayName: 'Preferences', icon: Icons.settings),
  contacts(displayName: 'Contacts', icon: Icons.import_contacts),
  reviews(displayName: 'Reviews', icon: Icons.star),
  addresses(displayName: 'Addresses', icon: Icons.location_on);

  const MyAccountOption({required this.displayName, required this.icon});

  final String displayName;
  final IconData icon;

  static MyAccountOption? fromName(String name) =>
      MyAccountOption.values.where((MyAccountOption option) => option.name == name).firstOrNull;
}
