import 'package:flutter/material.dart';

enum MyAccountOption {
  profile(displayName: 'Profile', icon: Icons.person),
  contacts(displayName: 'Contacts', icon: Icons.import_contacts),
  reviews(displayName: 'Reviews', icon: Icons.star);

  const MyAccountOption({required this.displayName, required this.icon});

  final String displayName;
  final IconData icon;

  static MyAccountOption fromName(String name) {
    final MyAccountOption? result =
        MyAccountOption.values.where((MyAccountOption option) => option.name == name).firstOrNull;
    if (result == null) {
      throw ArgumentError('Unknown MyAccountOption name: $name');
    }
    return result;
  }
}
