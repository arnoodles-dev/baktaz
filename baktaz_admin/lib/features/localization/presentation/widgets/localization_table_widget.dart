import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/localization/domain/cubit/localization_cubit.dart';
import 'package:baktaz_admin/features/localization/domain/cubit/localization_state.dart';
import 'package:baktaz_admin/features/localization/domain/entity/enum/localization_sort_criteria.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_tree_builder.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_table_footer.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_table_header.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_table_row.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_table_shimmer.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocalizationTableWidget extends StatelessWidget {
  const LocalizationTableWidget({required this.onEdit, super.key});

  final void Function(LocalizationKey, String?) onEdit;

  @override
  Widget build(BuildContext context) {
    final LocalizationCubit cubit = context.watch<LocalizationCubit>();

    final LocalizationState state = cubit.state;
    final Set<String> expandedNamespaces = state.expandedNamespaces;

    final List<LocalizationKey> allKeys = state.sortedKeys;
    final Map<String, LocalizationTranslation> pendingChanges = state.pendingChanges;
    final Set<int> addedKeyIds = state.addedKeyIds;
    final bool isLoading = state.status == const QueryStatus.loading();
    final String selectedLocale = state.selectedLocale;
    final List<String> locales = state.locales;
    final String searchQuery = state.searchQuery;

    if (allKeys.isEmpty && pendingChanges.isEmpty) {
      if (isLoading) {
        return const LocalizationTableShimmer();
      }
      return Center(
        child: Padding(
          padding: Paddings.allX2Large,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BaktazText(
                text: context.i18n.localization.table.no_keys_title,
                style: AppTextStyle.titleLarge.copyWith(fontWeight: AppFontWeight.semiBold),
              ),
              const Gap(AppSizes.xSmall),
              BaktazText(
                text: context.i18n.localization.table.no_keys_desc,
                style: AppTextStyle.bodyMedium.copyWith(color: AppColors.colorTextSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final List<LocalizationKey> paginatedKeys = state.paginatedKeys;
    final bool groupByNamespace = state.sortCriteria == LocalizationSortCriteria.namespace;

    final List<Widget> rowWidgets = <Widget>[];

    if (groupByNamespace) {
      final List<NamespaceNode> tree = buildLocalizationTree(paginatedKeys);

      for (final NamespaceNode nsNode in tree) {
        final int nsCount = allKeys.where((LocalizationKey k) => k.namespace == nsNode.namespace).length;
        final bool isCollapsed = !expandedNamespaces.contains(nsNode.namespace);

        rowWidgets.addAll(<Widget>[
          LocalizationTableRow(
            namespace: nsNode.namespace,
            count: nsCount,
            isCollapsed: isCollapsed,
            onToggle: () => context.read<LocalizationCubit>().toggleNamespace(nsNode.namespace),
          ),
          const Divider(height: 1, color: AppColors.colorBorder),
        ]);

        if (!isCollapsed) {
          rowWidgets.add(
            TreeRenderer(
              nodes: nsNode.children,
              depth: 1,
              pendingChanges: pendingChanges,
              expandedNamespaces: expandedNamespaces,
              selectedLocale: selectedLocale,
              onEdit: onEdit,
              addedKeyIds: addedKeyIds,
            ),
          );
        }
      }
    } else {
      for (final LocalizationKey locKey in paginatedKeys) {
        final String translationKey = '${locKey.id}_$selectedLocale';
        final LocalizationTranslation? pendingTranslation = pendingChanges[translationKey];
        final bool isNew = addedKeyIds.contains(locKey.id);
        final bool isModified = pendingTranslation != null && !isNew;

        rowWidgets.addAll(<Widget>[
          LocalizationRow(
            localizationKey: locKey,
            displayName: '${locKey.namespace}.${locKey.key}',
            depth: 0,
            pendingTranslation: pendingTranslation,
            isModified: isModified,
            isNew: isNew,
            selectedLocale: selectedLocale,
            onEdit: () =>
                onEdit(locKey, pendingTranslation?.value ?? (selectedLocale == 'en' ? locKey.defaultValueEn : null)),
          ),
          const Divider(height: 1, color: AppColors.colorBorder),
        ]);
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.colorBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LocalizationTableHeader(
            totalCount: state.totalItems,
            locales: locales,
            selectedLocale: selectedLocale,
            onLocaleSelected: cubit.selectLocale,
            searchQuery: searchQuery,
            onSearchChanged: cubit.setSearchQuery,
            onDownload: () {},
            pendingChanges: pendingChanges,
          ),
          const Divider(height: 1, color: AppColors.colorBorder),
          TableColumnHeaders(selectedLocale: selectedLocale),
          const Divider(height: 1, color: AppColors.colorBorder),
          ...rowWidgets,
          LocalizationTableFooter(
            startIndex: state.startIndex,
            endIndex: state.endIndex,
            totalItems: state.totalItems,
            currentPage: state.currentPage,
            totalPages: state.totalPages,
            onPageChanged: cubit.setPage,
            isNamespacePagination: groupByNamespace,
          ),
        ],
      ),
    );
  }
}
