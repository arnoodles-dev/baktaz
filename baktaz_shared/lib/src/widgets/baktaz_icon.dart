import 'package:baktaz_shared/src/theme/app_sizes.dart';
import 'package:baktaz_shared/src/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fpdart/fpdart.dart';

final class BaktazIcon extends StatelessWidget {
  const BaktazIcon({
    required this.icon,
    this.size,
    this.color,
    this.alignment = Alignment.center,
    this.child,
    super.key,
  });

  final Either<String, IconData> icon;
  final double? size;
  final Color? color;
  final Alignment alignment;
  final Widget? child;

  BaktazIcon copyWith({Color? copyColor}) =>
      BaktazIcon(icon: icon, color: copyColor, size: size, alignment: alignment, child: child);

  @override
  Widget build(BuildContext context) {
    final Widget? child = this.child;
    return child != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _Icon(icon: icon, size: size, alignment: alignment, color: color),
              Gap.large(),
              child,
            ],
          )
        : _Icon(icon: icon, size: size, alignment: alignment, color: color);
  }
}

class _Icon extends StatelessWidget {
  const _Icon({required this.icon, required this.size, required this.alignment, required this.color});

  final Either<String, IconData> icon;
  final double? size;
  final Alignment alignment;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color? color = this.color;
    return icon.fold(
      (String path) => SvgPicture.asset(
        path,
        height: size,
        width: size,
        alignment: alignment,
        colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      ),
      (IconData iconData) => Icon(iconData, color: color, size: size ?? AppSizes.large),
    );
  }
}
