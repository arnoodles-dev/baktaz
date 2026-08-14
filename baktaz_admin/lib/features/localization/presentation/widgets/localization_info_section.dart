import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class LocalizationInfoSection extends StatelessWidget {
  const LocalizationInfoSection({super.key});

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Expanded(child: _CoverageCard()),
        Gap.x2Large(),
        const Expanded(child: _ManageLanguagesCard()),
        Gap.x2Large(),
        const Expanded(child: _VersionManagementCard()),
      ],
    ),
  );
}

class _InfoCardContainer extends StatelessWidget {
  const _InfoCardContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: Paddings.allX2Large,
    decoration: BoxDecoration(
      color: context.colorScheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
      border: Border.fromBorderSide(BorderSide(color: context.colorScheme.outlineVariant)),
      boxShadow: <BoxShadow>[
        BoxShadow(color: context.colorScheme.shadow.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
      ],
    ),
    child: child,
  );
}

class _CoverageCard extends StatelessWidget {
  const _CoverageCard();

  @override
  Widget build(BuildContext context) => _InfoCardContainer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.baktazColors.warning.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
              ),
              child: Center(
                child: BaktazIcon(
                  icon: Either<String, IconData>.right(Icons.bolt),
                  size: AppSizes.size20,
                  color: context.baktazColors.warning,
                ),
              ),
            ),
            Gap.medium(),
            BaktazText(
              text: context.i18n.localization.info.coverage_title,
              style: AppTextStyle.titleMedium.copyWith(fontWeight: AppFontWeight.bold),
            ),
          ],
        ),
        Gap.large(),
        // Progress Bar
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.82,
            child: Container(
              decoration: BoxDecoration(
                color: context.baktazColors.warning,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
        ),
        Gap.medium(),
        BaktazText(
          text: context.i18n.localization.info.coverage_desc,
          style: AppTextStyle.bodyMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
        const Spacer(),
        Gap.large(),
        InkWell(
          onTap: () {},
          child: Row(
            children: <Widget>[
              BaktazText(
                text: context.i18n.localization.info.review_missing,
                style: AppTextStyle.labelMedium.copyWith(
                  color: context.baktazColors.warning,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
              Gap.small(),
              BaktazIcon(
                icon: Either<String, IconData>.right(Icons.arrow_forward),
                size: AppSizes.iconXSmall,
                color: context.baktazColors.warning,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ManageLanguagesCard extends StatelessWidget {
  const _ManageLanguagesCard();

  @override
  Widget build(BuildContext context) => _InfoCardContainer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
              ),
              child: Center(
                child: BaktazIcon(
                  icon: Either<String, IconData>.right(Icons.language),
                  size: AppSizes.size20,
                  color: context.colorScheme.primary,
                ),
              ),
            ),
            Gap.medium(),
            BaktazText(
              text: context.i18n.localization.info.manage_languages_title,
              style: AppTextStyle.titleMedium.copyWith(fontWeight: AppFontWeight.bold),
            ),
          ],
        ),
        Gap.medium(),
        BaktazText(
          text: context.i18n.localization.info.manage_languages_desc,
          style: AppTextStyle.bodyMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
        const Spacer(),
        Gap.large(),
        InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.small),
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BaktazIcon(
                  icon: Either<String, IconData>.right(Icons.add),
                  size: AppSizes.iconXSmall,
                  color: context.colorScheme.onPrimary,
                ),
                Gap.small(),
                BaktazText(
                  text: context.i18n.localization.info.add_locale,
                  style: AppTextStyle.labelMedium.copyWith(
                    color: context.colorScheme.onPrimary,
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Gap.medium(),
        InkWell(
          onTap: () {},
          child: Row(
            children: <Widget>[
              BaktazText(
                text: context.i18n.localization.info.locale_config,
                style: AppTextStyle.labelMedium.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
              Gap.small(),
              BaktazIcon(
                icon: Either<String, IconData>.right(Icons.arrow_forward),
                size: AppSizes.iconXSmall,
                color: context.colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _VersionManagementCard extends StatelessWidget {
  const _VersionManagementCard();

  @override
  Widget build(BuildContext context) => _InfoCardContainer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
              ),
              child: Center(
                child: BaktazIcon(
                  icon: Either<String, IconData>.right(Icons.history),
                  size: AppSizes.size20,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Gap.medium(),
            BaktazText(
              text: context.i18n.localization.info.version_management_title,
              style: AppTextStyle.titleMedium.copyWith(fontWeight: AppFontWeight.bold),
            ),
          ],
        ),
        Gap.medium(),
        BaktazText(
          text: context.i18n.localization.info.version_management_desc,
          style: AppTextStyle.bodyMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
        const Spacer(),
        Gap.large(),
        InkWell(
          onTap: () {},
          child: Row(
            children: <Widget>[
              BaktazText(
                text: context.i18n.localization.info.manage_versions,
                style: AppTextStyle.labelMedium.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
              Gap.small(),
              BaktazIcon(
                icon: Either<String, IconData>.right(Icons.arrow_forward),
                size: AppSizes.iconXSmall,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
