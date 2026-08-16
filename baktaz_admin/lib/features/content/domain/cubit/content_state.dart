import 'package:baktaz_admin/features/content/domain/entity/content_asset.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_asset_type.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_status.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_state.freezed.dart';

@freezed
abstract class ContentState with _$ContentState {
  const factory ContentState({
    @Default(QueryStatus.initial()) QueryStatus status,
    @Default(<ContentAsset>[]) List<ContentAsset> assets,
    @Default(<String, ContentAsset>{}) Map<String, ContentAsset> pendingChanges,
    String? selectedAssetId,
    ContentAssetType? selectedTypeFilter,
    ContentPlacementGroup? selectedPlacementFilter,
    @Default('') String searchQuery,
    @Default(false) bool isPublishing,
    @Default(<String>{}) Set<String> expandedGroups,
  }) = _ContentState;

  const ContentState._();

  ContentAsset? get selectedAsset {
    if (selectedAssetId == null) return null;
    return pendingChanges[selectedAssetId] ??
        assets.firstWhere((ContentAsset a) => a.id.getValue() == selectedAssetId, orElse: () => assets.first);
  }

  bool get hasPendingChanges => pendingChanges.isNotEmpty;

  bool isGroupExpanded(String group) => expandedGroups.contains(group);

  List<ContentAsset> get filteredAssets => assets.where((ContentAsset asset) {
    if (selectedTypeFilter != null && asset.type != selectedTypeFilter) {
      return false;
    }
    if (selectedPlacementFilter != null && asset.placementGroup != selectedPlacementFilter) {
      return false;
    }
    if (searchQuery.isNotEmpty) {
      final String query = searchQuery.toLowerCase();
      return asset.title.value.fold((_) => false, (String v) => v.toLowerCase().contains(query));
    }
    return true;
  }).toList();

  List<MapEntry<ContentPlacementGroup, List<ContentAsset>>> get groupedCarousels {
    final Map<ContentPlacementGroup, Map<ContentAssetType, List<ContentAsset>>> groups =
        <ContentPlacementGroup, Map<ContentAssetType, List<ContentAsset>>>{};
    for (final ContentAsset asset in filteredAssets) {
      groups.putIfAbsent(asset.placementGroup, () => <ContentAssetType, List<ContentAsset>>{});
      groups[asset.placementGroup]![asset.type] = (groups[asset.placementGroup]![asset.type] ?? <ContentAsset>[])
        ..add(asset);
    }
    return groups.entries
        .map(
          (MapEntry<ContentPlacementGroup, Map<ContentAssetType, List<ContentAsset>>> e) =>
              MapEntry<ContentPlacementGroup, List<ContentAsset>>(e.key, <ContentAsset>[
                for (final List<ContentAsset> assets in e.value.values) ...assets,
              ]),
        )
        .toList();
  }

  int get activeCount => assets.where((ContentAsset a) => a.status == ContentStatus.active).length;

  int get scheduledCount => assets.where((ContentAsset a) => a.status == ContentStatus.scheduled).length;

  int get draftCount => assets.where((ContentAsset a) => a.status == ContentStatus.draft).length;
}
