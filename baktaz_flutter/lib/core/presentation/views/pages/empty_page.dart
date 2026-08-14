import 'package:baktaz_flutter/app/constants/constant.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/widgets.dart';
import 'package:fpdart/fpdart.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({required this.title, required this.iconPath, this.subtitle, super.key});

  final String title;
  final String? subtitle;
  final String iconPath;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Constant.mobileBreakpoint),
      child: BaktazIcon(
        icon: left(iconPath),
        size: context.screenWidth * 0.5, // 50% of screen width
        child: Column(
          children: <Widget>[
            BaktazText(
              text: title,
              maxLines: 1,
              style: context.textTheme.headlineLarge?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
            Gap.small(),
            if (subtitle != null)
              FractionallySizedBox(
                widthFactor: 0.6, // 60% of screen width
                child: BaktazText(
                  text: subtitle!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: AppFontWeight.light,
                  ),
                ),
              ),
            if (subtitle == null) Gap.x2Large(),
          ],
        ),
      ),
    ),
  );
}
