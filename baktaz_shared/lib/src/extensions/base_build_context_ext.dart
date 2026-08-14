import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

extension BaseBuildContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  DefaultTextStyle get defaultTextStyle => DefaultTextStyle.of(this);

  bool get isDarkMode => theme.brightness == Brightness.dark;

  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  EdgeInsets get padding => MediaQuery.paddingOf(this);

  NavigatorState get navigator => Navigator.of(this);

  /// Custom design tokens (warning, badge variants, etc.) resolved from theme.
  BaktazCustomColors get baktazColors => theme.extension<BaktazCustomColors>() ?? BaktazCustomColors.light;
}
