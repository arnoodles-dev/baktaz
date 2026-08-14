import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/localization/domain/cubit/localization_cubit.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_tree_builder.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' hide State;

class LocalizationTableRow extends StatelessWidget {
  const LocalizationTableRow({
    required this.namespace,
    required this.count,
    required this.isCollapsed,
    required this.onToggle,
    super.key,
  });

  final String namespace;
  final int count;
  final bool isCollapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onToggle,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.xSmall),
      color: AppColors.colorSurfaceVariant.withValues(alpha: 0.3),
      child: Row(
        children: <Widget>[
          BaktazIcon(
            icon: Either<String, IconData>.right(isCollapsed ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_down),
            size: AppSizes.iconSmall,
            color: AppColors.colorTextSecondary,
          ),
          Gap.xSmall(),
          BaktazText(
            text: '$namespace ($count keys)'.toUpperCase(),
            style: AppTextStyle.labelMedium.copyWith(
              color: AppColors.colorTextSecondary,
              fontWeight: AppFontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ),
  );
}

class NestedGroupHeaderRow extends StatelessWidget {
  const NestedGroupHeaderRow({
    required this.name,
    required this.fullPath,
    required this.depth,
    required this.isCollapsed,
    required this.onToggle,
    super.key,
  });

  final String name;
  final String fullPath;
  final int depth;
  final bool isCollapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onToggle,
    child: Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.large + (depth * AppSizes.large),
        AppSizes.small,
        AppSizes.large,
        AppSizes.small,
      ),
      color: AppColors.colorSurfaceVariant.withValues(alpha: 0.15),
      child: Row(
        children: <Widget>[
          BaktazIcon(
            icon: Either<String, IconData>.right(isCollapsed ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_down),
            size: AppSizes.iconXSmall,
            color: AppColors.colorTextSecondary,
          ),
          Gap.xSmall(),
          BaktazText(
            text: name,
            style: AppTextStyle.bodyMedium.copyWith(color: AppColors.colorTextPrimary, fontWeight: AppFontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

class LocalizationRow extends StatelessWidget {
  const LocalizationRow({
    required this.localizationKey,
    required this.displayName,
    required this.depth,
    required this.pendingTranslation,
    required this.isModified,
    required this.isNew,
    required this.selectedLocale,
    required this.onEdit,
    super.key,
  });

  final LocalizationKey localizationKey;
  final String displayName;
  final int depth;
  final LocalizationTranslation? pendingTranslation;
  final bool isModified;
  final bool isNew;
  final String selectedLocale;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final String displayValue =
        pendingTranslation?.value ?? (selectedLocale == 'en' ? localizationKey.defaultValueEn : '');

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.large + (depth * AppSizes.large),
          AppSizes.medium,
          AppSizes.large,
          AppSizes.medium,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BaktazText(
                    text: displayName,
                    style: AppTextStyle.bodyMedium.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                      color: AppColors.colorTextPrimary,
                    ),
                  ),
                  if (localizationKey.description != null && localizationKey.description!.isNotEmpty) ...<Widget>[
                    Gap.x2Small(),
                    BaktazText(
                      text: localizationKey.description!,
                      style: AppTextStyle.bodySmall.copyWith(color: AppColors.colorTextDisabled),
                    ),
                  ],
                ],
              ),
            ),
            Gap.small(),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BaktazText(
                    text: displayValue,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: (isModified || isNew)
                          ? (isNew ? AppColors.successText : AppColors.warningText)
                          : AppColors.colorTextPrimary,
                      fontWeight: (isModified || isNew) ? AppFontWeight.semiBold : AppFontWeight.regular,
                    ),
                  ),
                  if (isModified || isNew) ...<Widget>[
                    Gap.x2Small(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xSmall, vertical: AppSizes.x3Small),
                      decoration: BoxDecoration(
                        color: isNew ? AppColors.colorAccentSubtle : AppColors.pendingSubtle,
                        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
                      ),
                      child: BaktazText(
                        text: isNew
                            ? context.i18n.localization.table.new_label
                            : context.i18n.localization.table.modified_label,
                        style: AppTextStyle.labelSmall.copyWith(
                          color: isNew ? AppColors.successText : AppColors.warningText,
                          fontWeight: AppFontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Gap.small(),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: BaktazButton(
                  onPressed: onEdit,
                  buttonType: ButtonType.text,
                  contentPadding: Paddings.allX2Small,
                  iconPadding: const EdgeInsets.only(left: AppSizes.x2Small),
                  icon: BaktazIcon(
                    icon: Either<String, IconData>.right(Icons.edit_outlined),
                    size: 14,
                    color: AppColors.colorPrimary,
                  ),
                  text: context.i18n.localization.table.edit,
                  textStyle: AppTextStyle.labelLarge.copyWith(color: AppColors.colorPrimary),
                  buttonStyle: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.x2Small),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TreeRenderer extends StatelessWidget {
  const TreeRenderer({
    required this.nodes,
    required this.depth,
    required this.pendingChanges,
    required this.expandedNamespaces,
    required this.selectedLocale,
    required this.onEdit,
    required this.addedKeyIds,
    super.key,
  });

  final List<TreeNode> nodes;
  final int depth;
  final Map<String, LocalizationTranslation> pendingChanges;
  final Set<String> expandedNamespaces;
  final String selectedLocale;
  final void Function(LocalizationKey, String?) onEdit;
  final Set<int> addedKeyIds;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = <Widget>[];

    for (final TreeNode node in nodes) {
      final bool isCollapsed = !expandedNamespaces.contains(node.fullPath);

      if (node is GroupNode) {
        widgets.addAll(<Widget>[
          NestedGroupHeaderRow(
            name: node.name,
            fullPath: node.fullPath,
            depth: depth,
            isCollapsed: isCollapsed,
            onToggle: () => context.read<LocalizationCubit>().toggleNamespace(node.fullPath),
          ),
          const Divider(height: 1, color: AppColors.colorBorder),
        ]);

        if (!isCollapsed) {
          widgets.add(
            TreeRenderer(
              nodes: node.children,
              depth: depth + 1,
              pendingChanges: pendingChanges,
              expandedNamespaces: expandedNamespaces,
              selectedLocale: selectedLocale,
              onEdit: onEdit,
              addedKeyIds: addedKeyIds,
            ),
          );
        }
      } else if (node is LeafNode) {
        final LocalizationKey locKey = node.localizationKey;
        final String translationKey = '${locKey.id}_$selectedLocale';
        final LocalizationTranslation? pendingTranslation = pendingChanges[translationKey];
        final bool isNew = addedKeyIds.contains(locKey.id);
        final bool isModified = pendingTranslation != null && !isNew;

        widgets.addAll(<Widget>[
          LocalizationRow(
            localizationKey: locKey,
            displayName: node.name,
            depth: depth,
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

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: widgets);
  }
}
