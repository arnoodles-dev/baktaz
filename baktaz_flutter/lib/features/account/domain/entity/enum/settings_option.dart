import 'package:flutter/material.dart';

enum SettingsOption {
  language(displayName: 'Language', icon: Icons.language),
  darkMode(displayName: 'Dark Mode', icon: Icons.contrast);

  const SettingsOption({required this.displayName, required this.icon});

  final String displayName;
  final IconData icon;

  static SettingsOption? fromName(String name) =>
      SettingsOption.values.where((SettingsOption option) => option.name == name).firstOrNull;
}
