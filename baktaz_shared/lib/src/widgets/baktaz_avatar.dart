import 'package:baktaz_shared/src/theme/app_sizes.dart';
import 'package:baktaz_shared/src/widgets/baktaz_icon.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BaktazAvatar extends StatelessWidget {
  const BaktazAvatar({
    required this.size,
    this.imageUrl,
    this.initials,
    this.padding,
    this.borderSize = AppSizes.x2Small,
    this.isCachedSize = true,
    this.isLoading = false,
    this.borderColor,
    this.cacheManager,
    this.maxSize,
    this.defaultIcon,
    super.key,
  });

  final double size;
  final String? imageUrl;
  final String? initials;
  final EdgeInsets? padding;
  final double borderSize;
  final bool isCachedSize;
  final bool isLoading;
  final Color? borderColor;
  final BaseCacheManager? cacheManager;
  final int? maxSize;
  final Either<String, IconData>? defaultIcon;

  // DESIGN.md §12.8 size constants
  static const double sizeXS = 24;
  static const double sizeSM = 36;
  static const double sizeMD = 44;
  static const double sizeLG = 64;
  static const double sizeXL = 88;

  @override
  Widget build(BuildContext context) {
    assert(initials == null || imageUrl == null, 'Cannot provide both imageUrl and initials');
    final ThemeData theme = Theme.of(context);
    final String? effectiveInitials = initials;
    // Show initials fallback if provided
    if (effectiveInitials != null) {
      return Semantics(
        image: true,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: _InitialsAvatar(initials: effectiveInitials, size: size),
        ),
      );
    }

    final String? effectiveImageUrl = imageUrl;
    return Semantics(
      image: true,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: effectiveImageUrl != null
            ? CachedNetworkImage(
                imageUrl: effectiveImageUrl,
                memCacheWidth: isCachedSize ? (size * MediaQuery.devicePixelRatioOf(context)).toInt() : null,
                memCacheHeight: isCachedSize ? (size * MediaQuery.devicePixelRatioOf(context)).toInt() : null,
                maxWidthDiskCache: maxSize,
                maxHeightDiskCache: maxSize,
                fadeOutDuration: Duration.zero,
                fadeInDuration: Duration.zero,
                placeholderFadeInDuration: Duration.zero,
                cacheManager: cacheManager,
                imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: borderSize, color: borderColor ?? theme.colorScheme.surface),
                    image: DecorationImage(
                      image: isCachedSize
                          ? ResizeImage(
                              imageProvider,
                              width: (size * MediaQuery.devicePixelRatioOf(context)).toInt(),
                              height: (size * MediaQuery.devicePixelRatioOf(context)).toInt(),
                            )
                          : imageProvider,
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                  ),
                  width: size,
                  height: size,
                ),
                errorWidget: (_, _, _) => _DefaultIcon(size: size, defaultIcon: defaultIcon),
                placeholder: (_, _) => Skeletonizer(
                  enabled: isLoading,
                  child: _DefaultIcon(size: size, defaultIcon: defaultIcon),
                ),
                fit: BoxFit.cover,
              )
            : _DefaultIcon(size: size, defaultIcon: defaultIcon),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials, required this.size});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String label = initials.characters.take(2).string.toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, shape: BoxShape.circle),
      child: Center(
        child: BaktazText(
          text: label,
          style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer),
        ),
      ),
    );
  }
}

class _DefaultIcon extends StatelessWidget {
  const _DefaultIcon({required this.size, this.defaultIcon});

  final double size;
  final Either<String, IconData>? defaultIcon;

  @override
  Widget build(BuildContext context) => Skeleton.replace(
    replacement: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
    ),
    child: BaktazIcon(icon: defaultIcon ?? right(Icons.account_circle), size: size),
  );
}
