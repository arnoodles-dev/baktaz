import 'package:baktaz_admin/features/localization/presentation/widgets/localization_table_header.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class LocalizationTableShimmer extends StatelessWidget {
  const LocalizationTableShimmer({super.key});

  @override
  Widget build(BuildContext context) => Shimmer(
    child: Container(
      decoration: const BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.colorBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: Paddings.allLarge,
            child: Row(
              children: <Widget>[
                BaktazText(text: 'All Keys', style: AppTextStyle.labelMedium),
                const Spacer(),
                BaktazText(text: 'Search keys...', style: AppTextStyle.labelMedium),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.colorBorder),
          const TableColumnHeaders(selectedLocale: 'en'),
          const Divider(height: 1, color: AppColors.colorBorder),
          ...List<Widget>.generate(
            5,
            (int index) => Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.medium),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: BaktazText(text: 'home.title', style: AppTextStyle.bodyMedium),
                      ),
                      Gap.small(),
                      Expanded(
                        flex: 4,
                        child: BaktazText(text: 'This is a long english translation', style: AppTextStyle.bodyMedium),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.colorBorder),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
