import 'package:baktaz_shared/src/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Shimmer extends StatelessWidget {
  const Shimmer({
    required this.child,
    this.enabled = true,
    this.ignorePointers = false,
    this.justifyMultiLineText = true,
    this.textBoneBorderRadius = const TextBoneBorderRadius(BorderRadius.all(Radius.circular(AppSizes.radiusXSmall))),
    this.containersColor,
    this.ignoreContainers,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final bool ignorePointers;
  final bool justifyMultiLineText;
  final TextBoneBorderRadius? textBoneBorderRadius;
  final Color? containersColor;
  final bool? ignoreContainers;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2);
    final Color highlightColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1);

    return Skeletonizer(
      enabled: enabled,
      ignorePointers: ignorePointers,
      justifyMultiLineText: justifyMultiLineText,
      textBoneBorderRadius: textBoneBorderRadius,
      containersColor: containersColor,
      ignoreContainers: ignoreContainers,
      effect: ShimmerEffect(
        baseColor: baseColor,
        highlightColor: highlightColor,
        duration: const Duration(milliseconds: 1200),
      ),
      child: child,
    );
  }
}
