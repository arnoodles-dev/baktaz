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
      padding: const EdgeInsets.fromLTRB(BaktazSpacing.lg, BaktazSpacing.md, BaktazSpacing.lg, BaktazSpacing.sm),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: locales.map((String locale) {
                  final bool isSelected = locale == selectedLocale;
                  return Padding(
                    padding: const EdgeInsets.only(right: BaktazSpacing.xs),
                    child: InkWell(
                      onTap: () => onLocaleSelected(locale),
                      borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.md, vertical: BaktazSpacing.sm),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border(
                                  bottom: BorderSide(color: context.colorScheme.primary, width: _borderBottomWidth),
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            BaktazText(
                              text: _getLocaleName(context, locale),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isSelected ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            if (pendingChanges.values
                                .where((LocalizationTranslation t) => t.locale == locale)
                                .isNotEmpty) ...<Widget>[
                              Gap.xSmall(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: context.colorScheme.primaryContainer,
                                  borderRadius: BaktazRadius.pill,
                                ),
                                child: BaktazText(
                                  text:
                                      '${pendingChanges.values.where((LocalizationTranslation t) => t.locale == locale).length}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
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
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
              border: Border.fromBorderSide(BorderSide(color: context.colorScheme.outline)),
            ),
            child: BaktazTextField(
              onChanged: onSearchChanged,
              controller: controller,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.sm, vertical: BaktazSpacing.xs),
                border: InputBorder.none,
                hintText: context.i18n.localization.table.search_placeholder,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.38)),
                prefixIcon: BaktazIcon(
                  icon: right(Icons.search),
                  size: _searchIconSize,
                  color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: _searchIconMinWidth, minHeight: _searchIconSize),
              ),
            ),
          ),
          Gap.small(),
          Container(width: _borderThickness, height: _dividerHeight, color: context.colorScheme.outline),
          Gap.small(),
          IconButton(
            onPressed: onDownload,
            icon: BaktazIcon(icon: right(Icons.download_outlined), color: context.colorScheme.onSurface),
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
      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: BaktazSpacing.sm),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: BaktazText(
              text: context.i18n.localization.table.key,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Gap.small(),
          Expanded(
            flex: 4,
            child: BaktazText(
              text: '$valueText(${selectedLocale.toUpperCase()})',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: BaktazText(
              text: context.i18n.localization.table.actions,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
