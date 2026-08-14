import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AccountDetailsContainer extends StatelessWidget {
  const AccountDetailsContainer({required this.child, this.isLoading = false, super.key});

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Skeletonizer(
    enabled: isLoading,
    child: Container(
      margin: Paddings.horizontalMedium,
      padding: Paddings.allMedium,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppTheme.defaultBorderRadius,
      ),
      child: child,
    ),
  );
}
