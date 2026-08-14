import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/content/domain/entity/content_asset.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_asset_type.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_status.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class ContentAssetTable extends StatelessWidget {
  const ContentAssetTable({
    required this.groupedCarousels,
    required this.selectedAssetId,
    required this.expandedGroups,
    required this.onAssetSelected,
    required this.onToggleGroup,
    super.key,
  });

  final List<MapEntry<ContentPlacementGroup, List<ContentAsset>>> groupedCarousels;
  final String? selectedAssetId;
  final Set<String> expandedGroups;
  final ValueChanged<String> onAssetSelected;
  final ValueChanged<String> onToggleGroup;

  @override
  Widget build(BuildContext context) {
    if (groupedCarousels.isEmpty) {
      return BaktazCard(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xLarge),
            child: BaktazText(
              text: context.i18n.content.table.empty_title,
              style: AppTextStyle.bodyLarge.copyWith(color: AppColors.colorTextSecondary),
            ),
          ),
        ),
      );
    }

    return Column(
      children: groupedCarousels.map((MapEntry<ContentPlacementGroup, List<ContentAsset>> group) {
        final Map<ContentAssetType, List<ContentAsset>> byType = <ContentAssetType, List<ContentAsset>>{};
        for (final ContentAsset asset in group.value) {
          byType.putIfAbsent(asset.type, () => <ContentAsset>[]).add(asset);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.small),
          child: _CarouselGroup(
            placementGroup: group.key,
            byType: byType,
            selectedAssetId: selectedAssetId,
            isExpanded: expandedGroups.contains(group.key.name),
            onAssetSelected: onAssetSelected,
            onToggleGroup: onToggleGroup,
          ),
        );
      }).toList(),
    );
  }
}

class _CarouselGroup extends StatelessWidget {
  const _CarouselGroup({
    required this.placementGroup,
    required this.byType,
    required this.selectedAssetId,
    required this.isExpanded,
    required this.onAssetSelected,
    required this.onToggleGroup,
  });

  final ContentPlacementGroup placementGroup;
  final Map<ContentAssetType, List<ContentAsset>> byType;
  final String? selectedAssetId;
  final bool isExpanded;
  final ValueChanged<String> onAssetSelected;
  final ValueChanged<String> onToggleGroup;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BaktazCard(
      headerTitle: context.i18n.content.table.placement_group_header(placement: placementGroup.displayName),
      headerAction: GestureDetector(
        onTap: () => onToggleGroup(placementGroup.name),
        child: AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(Icons.expand_more, color: colorScheme.onSurfaceVariant),
        ),
      ),
      body: AnimatedCrossFade(
        firstChild: const SizedBox.shrink(),
        secondChild: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final MapEntry<ContentAssetType, List<ContentAsset>> typeEntry in byType.entries) ...<Widget>[
              BaktazText(
                text: typeEntry.key.displayName,
                style: AppTextStyle.labelLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const Gap(AppSizes.xSmall),
              ...typeEntry.value.map(
                (ContentAsset asset) => _ContentAssetRow(
                  asset: asset,
                  isSelected: asset.id.getValue() == selectedAssetId,
                  onTap: () => onAssetSelected(asset.id.getValue()),
                ),
              ),
              const Gap(AppSizes.small),
            ],
          ],
        ),
        crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
      ),
    );
  }
}

class _ContentAssetRow extends StatelessWidget {
  const _ContentAssetRow({required this.asset, required this.isSelected, required this.onTap});

  final ContentAsset asset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.3) : AppColors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.small, vertical: AppSizes.xSmall),
          child: Row(
            children: <Widget>[
              _StatusDot(status: asset.status),
              const Gap(AppSizes.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    BaktazText(
                      text: asset.title.value.fold((_) => context.i18n.content.table.untitled_asset, (String v) => v),
                      style: AppTextStyle.bodyMedium.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    BaktazText(
                      text: context.i18n.content.table.order_label(
                        order: asset.orderIndex.value.fold((_) => 0, (num v) => v.toInt()),
                      ),
                      style: AppTextStyle.bodySmall.copyWith(color: AppColors.colorTextSecondary),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: asset.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final ContentStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      ContentStatus.active => Theme.of(context).colorScheme.primary,
      ContentStatus.scheduled => Theme.of(context).colorScheme.tertiary,
      ContentStatus.draft => Theme.of(context).colorScheme.outline,
    };

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ContentStatus status;

  @override
  Widget build(BuildContext context) {
    final (StatusBadgeVariant variant, String label) = switch (status) {
      ContentStatus.active => (StatusBadgeVariant.active, context.i18n.content.table.status_active),
      ContentStatus.scheduled => (StatusBadgeVariant.pending, context.i18n.content.table.status_scheduled),
      ContentStatus.draft => (StatusBadgeVariant.neutral, context.i18n.content.table.status_draft),
    };

    return BaktazStatusBadge(label: label, variant: variant);
  }
}
