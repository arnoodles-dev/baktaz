import 'package:baktaz_flutter/app/constants/constant.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class BaktazAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaktazAppBar({
    super.key,
    this.title,
    this.titleColor,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.leading,
    this.automaticallyImplyLeading = false,
    this.scrolledUnderElevation = 0,
    this.showTitle = true,
    this.bottom,
    this.size,
    this.elevation = 0,
    this.shadowColor,
    this.titleStyle,
  });

  final String? title;
  final TextStyle? titleStyle;
  final Size? size;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? shadowColor;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;
  final double? scrolledUnderElevation;
  final double? elevation;
  final bool showTitle;

  @override
  Size get preferredSize => size ?? Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) => AppBar(
    elevation: elevation,
    leading: leading,
    shadowColor: shadowColor,
    automaticallyImplyLeading: automaticallyImplyLeading,
    titleSpacing: leading != null ? 0 : null,
    title: showTitle
        ? Padding(
            padding: leading == null ? Paddings.leftXSmall : EdgeInsets.zero,
            child: BaktazText(text: title ?? Constant.appName, style: context.textTheme.headlineLarge),
          )
        : null,
    actions: actions,
    scrolledUnderElevation: scrolledUnderElevation,
    backgroundColor: backgroundColor ?? context.colorScheme.surface,
    surfaceTintColor: Colors.transparent,
    centerTitle: centerTitle,
    bottom: bottom,
  );
}
