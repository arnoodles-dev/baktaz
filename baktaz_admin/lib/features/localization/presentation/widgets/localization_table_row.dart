import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/localization/domain/cubit/localization_cubit.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_tree_builder.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: BaktazSpacing.xs),
      color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Row(
        children: <Widget>[
          BaktazIcon(
            icon: Either<String, IconData>.right(isCollapsed ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_down),
            size: BaktazSpacing.iconSmall,
            color: context.colorScheme.onSurfaceVariant,
          ),
          Gap.xSmall(),
          BaktazText(
            text: '$namespace ($count keys)'.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
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
        BaktazSpacing.lg + (depth * BaktazSpacing.lg),
        BaktazSpacing.sm,
        BaktazSpacing.lg,
        BaktazSpacing.sm,
      ),
      color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
      child: Row(
        children: <Widget>[
          BaktazIcon(
            icon: Either<String, IconData>.right(isCollapsed ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_down),
            size: BaktazSpacing.iconXSmall,
            color: context.colorScheme.onSurfaceVariant,
          ),
          Gap.xSmall(),
          BaktazText(
            text: name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurface, fontWeight: FontWeight.bold),
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
          BaktazSpacing.lg + (depth * BaktazSpacing.lg),
          BaktazSpacing.md,
          BaktazSpacing.lg,
          BaktazSpacing.md,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  if (localizationKey.description != null && localizationKey.description!.isNotEmpty) ...<Widget>[
                    Gap.x2Small(),
                    BaktazText(
                      text: localizationKey.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.38)),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: (isModified || isNew)
                          ? (isNew ? context.colorScheme.primary : context.baktazColors.warning)
                          : context.colorScheme.onSurface,
                      fontWeight: (isModified || isNew) ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isModified || isNew) ...<Widget>[
                    Gap.x2Small(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xs, vertical: BaktazSpacing.xs2),
                      decoration: BoxDecoration(
                        color: isNew ? context.colorScheme.primaryContainer : context.colorScheme.surfaceContainerHigh,
                        borderRadius: BaktazRadius.pill,
                      ),
                      child: BaktazText(
                        text: isNew
                            ? context.i18n.localization.table.new_label
                            : context.i18n.localization.table.modified_label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isNew ? context.colorScheme.primary : context.baktazColors.warning,
                          fontWeight: FontWeight.bold,
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
                  iconPadding: const EdgeInsets.only(left: BaktazSpacing.xs2),
                  icon: BaktazIcon(
                    icon: Either<String, IconData>.right(Icons.edit_outlined),
                    size: 14,
                    color: context.colorScheme.primary,
                  ),
                  text: context.i18n.localization.table.edit,
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.colorScheme.primary),
                  buttonStyle: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xs2),
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
          Divider(height: 1, color: context.colorScheme.outline),
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
          Divider(height: 1, color: context.colorScheme.outline),
        ]);
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: widgets);
  }
}
