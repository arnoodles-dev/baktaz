import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fpdart/fpdart.dart' show right;

const double _searchBarWidth = 250;
const double _searchBarHeight = 36;
const double _searchIconSize = 18;
const double _searchIconMinWidth = 32;
const double _dividerHeight = 24;
const double _borderThickness = 1;
const double _borderBottomWidth = 2;

class LocalizationTableHeader extends HookWidget {
  const LocalizationTableHeader({
    required this.totalCount,
    required this.locales,
    required this.selectedLocale,
    required this.onLocaleSelected,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onDownload,
    required this.pendingChanges,
    super.key,
  });

  final int totalCount;
  final List<String> locales;
  final String selectedLocale;
  final void Function(String) onLocaleSelected;
  final String searchQuery;
  final void Function(String) onSearchChanged;
  final VoidCallback onDownload;
  final Map<String, LocalizationTranslation> pendingChanges;

  String _getLocaleName(BuildContext context, String locale) {
    switch (locale) {
      case 'en':
        return context.i18n.localization.languages.en;
      case 'es':
        return context.i18n.localization.languages.es;
      case 'de':
        return context.i18n.localization.languages.de;
      default:
        return locale.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = useTextEditingController(text: searchQuery);

    useEffect(() {
      if (searchQuery != controller.text) {
        controller.text = searchQuery;
      }
      return null;
    }, <Object>[searchQuery]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.large, AppSizes.medium, AppSizes.large, AppSizes.small),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: locales.map((String locale) {
                  final bool isSelected = locale == selectedLocale;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.xSmall),
                    child: InkWell(
                      onTap: () => onLocaleSelected(locale),
                      borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.medium, vertical: AppSizes.small),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? const Border(
                                  bottom: BorderSide(color: AppColors.colorPrimary, width: _borderBottomWidth),
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            BaktazText(
                              text: _getLocaleName(context, locale),
                              style: AppTextStyle.titleMedium.copyWith(
                                color: isSelected ? AppColors.colorPrimary : AppColors.colorTextSecondary,
                                fontWeight: isSelected ? AppFontWeight.semiBold : AppFontWeight.regular,
                              ),
                            ),
                            if (pendingChanges.values
                                .where((LocalizationTranslation t) => t.locale == locale)
                                .isNotEmpty) ...<Widget>[
                              Gap.xSmall(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: const BoxDecoration(
                                  color: AppColors.colorPrimarySubtle,
                                  borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
                                ),
                                child: BaktazText(
                                  text:
                                      '${pendingChanges.values.where((LocalizationTranslation t) => t.locale == locale).length}',
                                  style: AppTextStyle.bodySmall.copyWith(
                                    color: AppColors.colorPrimary,
                                    fontWeight: AppFontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Gap.medium(),
          Container(
            width: _searchBarWidth,
            height: _searchBarHeight,
            decoration: const BoxDecoration(
              color: AppColors.colorSurface,
              borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
              border: Border.fromBorderSide(BorderSide(color: AppColors.colorBorder)),
            ),
            child: BaktazTextField(
              onChanged: onSearchChanged,
              controller: controller,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.small, vertical: AppSizes.xSmall),
                border: InputBorder.none,
                hintText: context.i18n.localization.table.search_placeholder,
                hintStyle: AppTextStyle.bodyMedium.copyWith(color: AppColors.colorTextDisabled),
                prefixIcon: BaktazIcon(
                  icon: right(Icons.search),
                  size: _searchIconSize,
                  color: AppColors.colorTextDisabled,
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: _searchIconMinWidth, minHeight: _searchIconSize),
              ),
            ),
          ),
          Gap.small(),
          Container(width: _borderThickness, height: _dividerHeight, color: AppColors.colorBorder),
          Gap.small(),
          IconButton(
            onPressed: onDownload,
            icon: BaktazIcon(icon: right(Icons.download_outlined), color: AppColors.colorTextPrimary),
            tooltip: context.i18n.localization.table.download,
          ),
        ],
      ),
    );
  }
}

class TableColumnHeaders extends StatelessWidget {
  const TableColumnHeaders({required this.selectedLocale, super.key});

  final String selectedLocale;

  @override
  Widget build(BuildContext context) {
    final String valueText = context.i18n.localization.table.value_en.split('(').first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.small),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: BaktazText(
              text: context.i18n.localization.table.key,
              style: AppTextStyle.labelMedium.copyWith(
                color: AppColors.colorTextDisabled,
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
          ),
          Gap.small(),
          Expanded(
            flex: 4,
            child: BaktazText(
              text: '$valueText(${selectedLocale.toUpperCase()})',
              style: AppTextStyle.labelMedium.copyWith(
                color: AppColors.colorTextDisabled,
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
          ),
          Expanded(
            child: BaktazText(
              text: context.i18n.localization.table.actions,
              style: AppTextStyle.labelMedium.copyWith(
                color: AppColors.colorTextDisabled,
                fontWeight: AppFontWeight.semiBold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
