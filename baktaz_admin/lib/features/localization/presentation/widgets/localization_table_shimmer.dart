import 'package:baktaz_admin/features/localization/presentation/widgets/localization_table_header.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class LocalizationTableShimmer extends StatelessWidget {
  const LocalizationTableShimmer({super.key});

  @override
  Widget build(BuildContext context) => Shimmer(
    child: Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
        border: Border.fromBorderSide(BorderSide(color: context.colorScheme.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: Paddings.allLarge,
            child: Row(
              children: <Widget>[
                BaktazText(text: 'All Keys', style: Theme.of(context).textTheme.labelMedium),
                const Spacer(),
                BaktazText(text: 'Search keys...', style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
          Divider(height: 1, color: context.colorScheme.outline),
          const TableColumnHeaders(selectedLocale: 'en'),
          Divider(height: 1, color: context.colorScheme.outline),
          ...List<Widget>.generate(
            5,
            (int index) => Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: BaktazSpacing.md),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: BaktazText(text: 'home.title', style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      Gap.small(),
                      Expanded(
                        flex: 4,
                        child: BaktazText(text: 'This is a long english translation', style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ),
                Divider(height: 1, color: context.colorScheme.outline),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
