import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_content_tile.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_tile_header.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

final class AccountContentWidget extends StatelessWidget {
  const AccountContentWidget({required this.groupedOptions, required this.onOptionsTap, super.key});

  final Map<AccountHeader, List<String>> groupedOptions;
  final void Function(String title) onOptionsTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: Paddings.horizontalMedium,
    child: CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      slivers: groupedOptions.entries.toList().asMap().entries.map<Widget>((
        MapEntry<int, MapEntry<AccountHeader, List<String>>> entry,
      ) {
        final int index = entry.key;
        final MapEntry<AccountHeader, List<String>> options = entry.value;

        return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              if (index > 0) Gap.medium(),
              _ContentContainer(options: options, onOptionsTap: onOptionsTap),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

class _ContentContainer extends StatelessWidget {
  const _ContentContainer({required this.options, required this.onOptionsTap});

  final MapEntry<AccountHeader, List<String>> options;
  final void Function(String title) onOptionsTap;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: context.colorScheme.surfaceContainer, borderRadius: AppTheme.defaultBorderRadius),
    padding: Paddings.allMedium,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AccountTileHeader(header: options.key),
        Gap.medium(),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: options.value.length > 2 ? 2 : 1,
            childAspectRatio: options.value.length > 2 ? 4 : 8,
            mainAxisSpacing: AppSizes.xSmall,
            crossAxisSpacing: AppSizes.xSmall,
          ),
          itemCount: options.value.length,
          itemBuilder: (BuildContext context, int index) => AccountContentTile(
            title: options.value[index],
            onTap: () => onOptionsTap(options.value[index]),
            optionKey: options.key,
          ),
        ),
      ],
    ),
  );
}
