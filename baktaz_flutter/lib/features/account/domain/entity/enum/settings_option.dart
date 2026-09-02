import 'package:flutter/material.dart';

enum SettingsOption {
  darkMode(displayName: 'Dark Mode', icon: Icons.contrast);

  const SettingsOption({required this.displayName, required this.icon});

  final String displayName;
  final IconData icon;

  static SettingsOption fromName(String name) {
    final SettingsOption? result =
        SettingsOption.values.where((SettingsOption option) => option.name == name).firstOrNull;
    if (result == null) {
      throw ArgumentError('Unknown SettingsOption name: $name');
    }
    return result;
  }
}
