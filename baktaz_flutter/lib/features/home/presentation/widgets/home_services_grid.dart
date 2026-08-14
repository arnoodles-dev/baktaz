import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class HomeServicesGrid extends StatelessWidget {
  const HomeServicesGrid({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.medium, vertical: AppSizes.xSmall),
    child: GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: AppSizes.medium,
      crossAxisSpacing: AppSizes.medium,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.75,
      children: <Widget>[
        _ServiceCard(
          icon: Icons.local_mall,
          label: context.i18n.home.services_list.shops,
          onTap: () {
            //TODO: navigate to Shops screen
          },
        ),
        _ServiceCard(
          icon: Icons.request_quote,
          label: context.i18n.home.services_list.requests,
          onTap: () {
            //TODO: navigate to Requests screen
          },
        ),
        _ServiceCard(
          icon: Icons.person,
          label: context.i18n.home.services_list.heroes,
          onTap: () {
            //TODO: navigate to Heroes screen
          },
        ),
        _ServiceCard(
          icon: Icons.inventory_2,
          label: context.i18n.home.services_list.express,
          onTap: () {
            //TODO: navigate to Express screen
          },
        ),
      ],
    ),
  );
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.colorScheme.surface,
      borderRadius: AppTheme.cardBorderRadius,
      border: Border.all(color: context.colorScheme.secondaryContainer, width: 1.5),
    ),
    child: Material(
      color: AppColors.transparent,
      borderRadius: AppTheme.cardBorderRadius,
      child: InkWell(
        borderRadius: AppTheme.cardBorderRadius,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.primary.withValues(alpha: 0.15),
              ),
              padding: Paddings.allSmall,
              child: BaktazIcon(icon: right(icon), size: AppSizes.iconLarge, color: context.colorScheme.primary),
            ),
            Gap.small(),
            BaktazText(
              text: label,
              style: context.textTheme.bodyMedium?.copyWith(fontWeight: AppFontWeight.semiBold),
            ),
          ],
        ),
      ),
    ),
  );
}
