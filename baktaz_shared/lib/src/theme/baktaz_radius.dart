import 'package:flutter/material.dart';

class BaktazRadius {
  BaktazRadius._();

  // Simple scale (double values)
  static const double sm = 4;
  static const double base = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double full = 999;

  // Aliases
  static const double small = sm;
  static const double medium = lg;
  static const double large = xl2;

  // Named BorderRadius getters (DESIGN.md §0.4)
  static BorderRadius get card => const BorderRadius.all(Radius.circular(xl2)); // Hero card, Community Pulse card
  static BorderRadius get row => const BorderRadius.all(Radius.circular(lg)); // Leaderboard rows
  static BorderRadius get chip => const BorderRadius.all(Radius.circular(md)); // Pool / Stake sub-cards
  static BorderRadius get pill => const BorderRadius.all(Radius.circular(full)); // Badges, FAB, avatars
}
