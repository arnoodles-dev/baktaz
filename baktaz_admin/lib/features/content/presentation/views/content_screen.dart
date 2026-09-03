import 'dart:async';

import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/features/content/domain/cubit/content_cubit.dart';
import 'package:baktaz_admin/features/content/domain/cubit/content_state.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_asset_type.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_admin/features/content/presentation/widgets/content_asset_table.dart';
import 'package:baktaz_admin/features/content/presentation/widgets/content_config_panel.dart';
import 'package:baktaz_admin/features/content/presentation/widgets/content_page_header.dart';
import 'package:baktaz_admin/features/content/presentation/widgets/content_pending_changes_banner.dart';
import 'package:baktaz_admin/features/content/presentation/widgets/content_stats_section.dart';
import 'package:baktaz_admin/features/content/presentation/widgets/content_table_header.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ContentCubit cubit = getIt<ContentCubit>();
    unawaited(cubit.loadAssets());
    return BlocSignalProvider<ContentCubit>.value(
      value: cubit,
      child: const LoaderOverlay(child: _ContentScreenView()),
    );
  }
}

class _ContentScreenView extends StatelessWidget {
  const _ContentScreenView();

  @override
  Widget build(BuildContext context) => BlocSignalConsumer<ContentCubit, ContentState>(
    listenWhen: (ContentState prev, ContentState curr) =>
        prev.status != curr.status ||
        prev.isPublishing != curr.isPublishing ||
        (prev.pendingChanges.isNotEmpty && curr.pendingChanges.isEmpty),
    listener: (BuildContext context, ContentState state) {
      if ((state.status.isLoading && state.assets.isNotEmpty) || state.isPublishing) {
        context.loaderOverlay.show();
      } else {
        context.loaderOverlay.hide();
      }
    },
    builder: (BuildContext context, ContentState state) {
      final ContentCubit cubit = context.read<ContentCubit>();

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(BaktazSpacing.md, BaktazSpacing.md, BaktazSpacing.md, BaktazSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (state.hasPendingChanges) ...<Widget>[
              ContentPendingChangesBanner(
                changeCount: state.pendingChanges.length,
                onPublish: cubit.publishChanges,
                onDiscard: cubit.discardChanges,
              ),
              Gap.x2Large(),
            ],
            ContentStatsSection(
              activeCount: state.activeCount,
              scheduledCount: state.scheduledCount,
              draftCount: state.draftCount,
            ),
            Gap.xLarge(),
            ContentPageHeader(
              onSaveDraft: cubit.submitDraft,
              onPublish: cubit.publishChanges,
              isPublishing: state.isPublishing,
              hasPendingChanges: state.hasPendingChanges,
            ),
            Gap.xLarge(),
            ContentTableHeader(
              selectedType: state.selectedTypeFilter,
              selectedPlacement: state.selectedPlacementFilter,
              searchQuery: state.searchQuery,
              onTypeFilterChanged: (ContentAssetType? type) => cubit.setFilter(type: type),
              onPlacementFilterChanged: (ContentPlacementGroup? placement) => cubit.setFilter(placement: placement),
              onSearchChanged: (String query) => cubit.setFilter(search: query),
            ),
            Gap.xLarge(),
            ContentAssetTable(
              groupedCarousels: state.groupedCarousels,
              selectedAssetId: state.selectedAssetId,
              expandedGroups: state.expandedGroups,
              onAssetSelected: (String id) => cubit.selectAsset(id == state.selectedAssetId ? null : id),
              onToggleGroup: cubit.toggleGroup,
            ),
            Gap.xLarge(),
            ContentConfigPanel(
              asset: state.selectedAsset,
              onSave: cubit.updateDraft,
              onCancel: () => cubit.selectAsset(null),
            ),
          ],
        ),
      );
    },
  );
}
