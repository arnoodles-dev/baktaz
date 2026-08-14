import 'dart:async';

import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
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
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<ContentCubit>(
    create: (_) {
      final ContentCubit cubit = getIt<ContentCubit>();
      unawaited(cubit.loadAssets());
      return cubit;
    },
    child: const LoaderOverlay(child: _ContentScreenView()),
  );
}

class _ContentScreenView extends StatelessWidget {
  const _ContentScreenView();

  @override
  Widget build(BuildContext context) => BlocPresentationListener<ContentCubit, ContentPresentationEvent>(
    listener: (BuildContext context, ContentPresentationEvent event) {
      event.when(
        onPublishSuccess: () {
          toastification.show(
            context: context,
            title: BaktazText(text: context.i18n.content.publish_success),
            autoCloseDuration: const Duration(seconds: 4),
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            alignment: Alignment.topCenter,
          );
        },
        onScheduleSuccess: () {
          toastification.show(
            context: context,
            title: BaktazText(text: context.i18n.content.schedule_success),
            autoCloseDuration: const Duration(seconds: 4),
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            alignment: Alignment.topCenter,
          );
        },
        showLoader: () => context.loaderOverlay.show(),
        hideLoader: () => context.loaderOverlay.hide(),
      );
    },
    child: BlocConsumer<ContentCubit, ContentState>(
      listenWhen: (ContentState prev, ContentState curr) => prev.status != curr.status,
      listener: (BuildContext context, ContentState state) {
        if (state.status.isLoading && state.assets.isNotEmpty) {
          context.loaderOverlay.show();
        } else {
          context.loaderOverlay.hide();
        }
      },
      builder: (BuildContext context, ContentState state) {
        final ContentCubit cubit = context.read<ContentCubit>();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSizes.medium, AppSizes.medium, AppSizes.medium, AppSizes.xLarge),
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
    ),
  );
}
