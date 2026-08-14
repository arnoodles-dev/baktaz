import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skeletonizer/skeletonizer.dart';

final class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    required this.isLoading,
    required this.onChangeAddress,
    required this.name,
    this.profileImage,
    super.key,
    this.greeting,
  });

  final bool isLoading;
  final VoidCallback onChangeAddress;
  final String name;
  final String? greeting;

  final String? profileImage;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: Paddings.horizontalLarge,
        child: Skeletonizer(
          enabled: isLoading,
          child: Skeleton.leaf(
            child: SizedBox(
              height: AppTheme.defaultAppBarHeight,
              child: Row(
                children: <Widget>[
                  BaktazAvatar(size: AppSizes.iconXLarge, imageUrl: profileImage),
                  Gap.medium(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        BaktazText(
                          text: greeting ?? context.i18n.home.greeting_fallback,
                          style: context.textTheme.labelLarge?.copyWith(fontWeight: AppFontWeight.light),
                        ),
                        Gap.x2Small(),
                        BaktazText(
                          text: name,
                          style: context.textTheme.titleLarge?.copyWith(fontWeight: AppFontWeight.semiBold),
                        ),
                      ],
                    ),
                  ),

                  Gap.xSmall(),
                  GestureDetector(
                    onTap: onChangeAddress,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colorScheme.primary.withValues(alpha: 38 / 255),
                      ),
                      padding: Paddings.allXSmall,
                      child: BaktazIcon(
                        icon: right(Icons.location_on),
                        size: AppSizes.iconMedium,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
