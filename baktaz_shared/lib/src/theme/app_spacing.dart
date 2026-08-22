import 'package:baktaz_shared/src/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' as gap;

// ignore_for_file: prefer-match-file-name, avoid-returning-widgets
final class Gap extends StatelessWidget {
  const Gap(this._size, {super.key});

  factory Gap.x3Small() => const Gap(AppSizes.x3Small);
  factory Gap.x2Small() => const Gap(AppSizes.x2Small);
  factory Gap.xSmall() => const Gap(AppSizes.xSmall);
  factory Gap.small() => const Gap(AppSizes.small);
  factory Gap.medium() => const Gap(AppSizes.medium);
  factory Gap.large() => const Gap(AppSizes.large);
  factory Gap.xLarge() => const Gap(AppSizes.xLarge);
  factory Gap.x2Large() => const Gap(AppSizes.x2Large);
  factory Gap.x3Large() => const Gap(AppSizes.x3Large);
  factory Gap.x4Large() => const Gap(AppSizes.x4Large);
  factory Gap.custom(double size) => Gap(size);

  final double _size;

  @override
  Widget build(BuildContext context) => gap.Gap(_size);
}

abstract final class Paddings {
  static const EdgeInsets screenMarginH = EdgeInsets.symmetric(horizontal: AppSizes.screenMarginH);

  // all paddings
  static const EdgeInsets allX3Small = EdgeInsets.all(AppSizes.x3Small);
  static const EdgeInsets allX2Small = EdgeInsets.all(AppSizes.x2Small);
  static const EdgeInsets allXSmall = EdgeInsets.all(AppSizes.xSmall);
  static const EdgeInsets allSmall = EdgeInsets.all(AppSizes.small);
  static const EdgeInsets allMedium = EdgeInsets.all(AppSizes.medium);
  static const EdgeInsets allLarge = EdgeInsets.all(AppSizes.large);
  static const EdgeInsets allXLarge = EdgeInsets.all(AppSizes.xLarge);
  static const EdgeInsets allX2Large = EdgeInsets.all(AppSizes.x2Large);
  static const EdgeInsets allX3Large = EdgeInsets.all(AppSizes.x3Large);
  static const EdgeInsets allX4Large = EdgeInsets.all(AppSizes.x4Large);

  // horizontal paddings
  static const EdgeInsets horizontalX3Small = EdgeInsets.symmetric(horizontal: AppSizes.x3Small);
  static const EdgeInsets horizontalX2Small = EdgeInsets.symmetric(horizontal: AppSizes.x2Small);
  static const EdgeInsets horizontalXSmall = EdgeInsets.symmetric(horizontal: AppSizes.xSmall);
  static const EdgeInsets horizontalSmall = EdgeInsets.symmetric(horizontal: AppSizes.small);
  static const EdgeInsets horizontalMedium = EdgeInsets.symmetric(horizontal: AppSizes.medium);
  static const EdgeInsets horizontalLarge = EdgeInsets.symmetric(horizontal: AppSizes.large);
  static const EdgeInsets horizontalXLarge = EdgeInsets.symmetric(horizontal: AppSizes.xLarge);
  static const EdgeInsets horizontalX2Large = EdgeInsets.symmetric(horizontal: AppSizes.x2Large);
  static const EdgeInsets horizontalX3Large = EdgeInsets.symmetric(horizontal: AppSizes.x3Large);
  static const EdgeInsets horizontalX4Large = EdgeInsets.symmetric(horizontal: AppSizes.x4Large);

  // vertical paddings
  static const EdgeInsets verticalX3Small = EdgeInsets.symmetric(vertical: AppSizes.x3Small);
  static const EdgeInsets verticalX2Small = EdgeInsets.symmetric(vertical: AppSizes.x2Small);
  static const EdgeInsets verticalXSmall = EdgeInsets.symmetric(vertical: AppSizes.xSmall);
  static const EdgeInsets verticalSmall = EdgeInsets.symmetric(vertical: AppSizes.small);
  static const EdgeInsets verticalMedium = EdgeInsets.symmetric(vertical: AppSizes.medium);
  static const EdgeInsets verticalLarge = EdgeInsets.symmetric(vertical: AppSizes.large);
  static const EdgeInsets verticalXLarge = EdgeInsets.symmetric(vertical: AppSizes.xLarge);
  static const EdgeInsets verticalX2Large = EdgeInsets.symmetric(vertical: AppSizes.x2Large);
  static const EdgeInsets verticalX3Large = EdgeInsets.symmetric(vertical: AppSizes.x3Large);
  static const EdgeInsets verticalX4Large = EdgeInsets.symmetric(vertical: AppSizes.x4Large);

  // left paddings
  static const EdgeInsets leftX3Small = EdgeInsets.only(left: AppSizes.x3Small);
  static const EdgeInsets leftX2Small = EdgeInsets.only(left: AppSizes.x2Small);
  static const EdgeInsets leftXSmall = EdgeInsets.only(left: AppSizes.xSmall);
  static const EdgeInsets leftSmall = EdgeInsets.only(left: AppSizes.small);
  static const EdgeInsets leftMedium = EdgeInsets.only(left: AppSizes.medium);
  static const EdgeInsets leftLarge = EdgeInsets.only(left: AppSizes.large);
  static const EdgeInsets leftXLarge = EdgeInsets.only(left: AppSizes.xLarge);
  static const EdgeInsets leftX2Large = EdgeInsets.only(left: AppSizes.x2Large);
  static const EdgeInsets leftX3Large = EdgeInsets.only(left: AppSizes.x3Large);
  static const EdgeInsets leftX4Large = EdgeInsets.only(left: AppSizes.x4Large);

  // right paddings
  static const EdgeInsets rightX3Small = EdgeInsets.only(right: AppSizes.x3Small);
  static const EdgeInsets rightX2Small = EdgeInsets.only(right: AppSizes.x2Small);
  static const EdgeInsets rightXSmall = EdgeInsets.only(right: AppSizes.xSmall);
  static const EdgeInsets rightSmall = EdgeInsets.only(right: AppSizes.small);
  static const EdgeInsets rightMedium = EdgeInsets.only(right: AppSizes.medium);
  static const EdgeInsets rightLarge = EdgeInsets.only(right: AppSizes.large);
  static const EdgeInsets rightXLarge = EdgeInsets.only(right: AppSizes.xLarge);
  static const EdgeInsets rightX2Large = EdgeInsets.only(right: AppSizes.x2Large);
  static const EdgeInsets rightX3Large = EdgeInsets.only(right: AppSizes.x3Large);
  static const EdgeInsets rightX4Large = EdgeInsets.only(right: AppSizes.x4Large);

  // top paddings
  static const EdgeInsets topX3Small = EdgeInsets.only(top: AppSizes.x3Small);
  static const EdgeInsets topX2Small = EdgeInsets.only(top: AppSizes.x2Small);
  static const EdgeInsets topXSmall = EdgeInsets.only(top: AppSizes.xSmall);
  static const EdgeInsets topSmall = EdgeInsets.only(top: AppSizes.small);
  static const EdgeInsets topMedium = EdgeInsets.only(top: AppSizes.medium);
  static const EdgeInsets topLarge = EdgeInsets.only(top: AppSizes.large);
  static const EdgeInsets topXLarge = EdgeInsets.only(top: AppSizes.xLarge);
  static const EdgeInsets topX2Large = EdgeInsets.only(top: AppSizes.x2Large);
  static const EdgeInsets topX3Large = EdgeInsets.only(top: AppSizes.x3Large);
  static const EdgeInsets topX4Large = EdgeInsets.only(top: AppSizes.x4Large);

  // bottom paddings
  static const EdgeInsets bottomX3Small = EdgeInsets.only(bottom: AppSizes.x3Small);
  static const EdgeInsets bottomX2Small = EdgeInsets.only(bottom: AppSizes.x2Small);
  static const EdgeInsets bottomXSmall = EdgeInsets.only(bottom: AppSizes.xSmall);
  static const EdgeInsets bottomSmall = EdgeInsets.only(bottom: AppSizes.small);
  static const EdgeInsets bottomMedium = EdgeInsets.only(bottom: AppSizes.medium);
  static const EdgeInsets bottomLarge = EdgeInsets.only(bottom: AppSizes.large);
  static const EdgeInsets bottomXLarge = EdgeInsets.only(bottom: AppSizes.xLarge);
  static const EdgeInsets bottomX2Large = EdgeInsets.only(bottom: AppSizes.x2Large);
  static const EdgeInsets bottomX3Large = EdgeInsets.only(bottom: AppSizes.x3Large);
  static const EdgeInsets bottomX4Large = EdgeInsets.only(bottom: AppSizes.x4Large);
}
