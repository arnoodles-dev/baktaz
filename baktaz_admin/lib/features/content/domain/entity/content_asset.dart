import 'package:baktaz_admin/features/content/domain/entity/enum/content_asset_type.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_status.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_asset.freezed.dart';

@freezed
abstract class ContentAsset with _$ContentAsset {
  const factory ContentAsset({
    required UniqueId id,
    required ValueString title,
    required ContentAssetType type,
    required ContentPlacementGroup placementGroup,
    required ValueNumeric orderIndex,
    required ContentStatus status,
    Url? routeUrl,
    Url? imageUrl,
    ValueJson? metadataJson,
    LocalDateTime? scheduleStart,
    LocalDateTime? scheduleEnd,
    LocalDateTime? lastModified,
  }) = _ContentAsset;

  const ContentAsset._();

  Option<Failure> get validate => id.validate
      .andThen(() => title.validate)
      .andThen(() => orderIndex.validate)
      .andThen(() => routeUrl?.validate ?? right(unit))
      .andThen(() => imageUrl?.validate ?? right(unit))
      .andThen(() => metadataJson?.validate ?? right(unit))
      .fold(some, (_) => none());
}
