import 'package:flutter/material.dart';

enum SupportOption {
  helpCenter(displayName: 'Help Center', icon: Icons.help, configKey: 'help_center_url'),
  aboutUs(displayName: 'About Us', icon: Icons.info, configKey: 'about_us_url'),
  privacyPolicy(displayName: 'Privacy Policy', icon: Icons.policy, configKey: 'privacy_policy_url'),
  shareFeedback(displayName: 'Share Feedback', icon: Icons.reviews, configKey: 'share_feedback_url');

  const SupportOption({required this.displayName, required this.icon, required this.configKey});

  final String displayName;
  final IconData icon;
  final String configKey;

  static SupportOption? fromName(String name) =>
      SupportOption.values.where((SupportOption option) => option.name == name).firstOrNull;
}
