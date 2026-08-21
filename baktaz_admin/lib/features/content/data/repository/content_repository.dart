import 'package:baktaz_admin/features/content/domain/entity/content_asset.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_asset_type.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_status.dart';
import 'package:baktaz_admin/features/content/domain/interface/i_content_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IContentRepository)
final class ContentRepository implements IContentRepository {
  static const Duration _defaultDelay = Duration(milliseconds: 400);
  static const Duration _saveDelay = Duration(milliseconds: 600);

  final List<ContentAsset> _assets = <ContentAsset>[
    ContentAsset(
      id: UniqueId.fromUniqueString('a1b2c3d4-0001'),
      title: ValueString('Summer Promo Banner', fieldName: 'title'),
      type: ContentAssetType.banner,
      placementGroup: ContentPlacementGroup.home,
      orderIndex: ValueNumeric(1, fieldName: 'orderIndex'),
      status: ContentStatus.active,
      routeUrl: Url('https://example.com/summer'),
      imageUrl: Url('https://cdn.example.com/images/summer-banner.jpg'),
      lastModified: LocalDateTime(DateTime(2026, 7, 15)),
    ),
    ContentAsset(
      id: UniqueId.fromUniqueString('a1b2c3d4-0002'),
      title: ValueString('App Install Ad', fieldName: 'title'),
      type: ContentAssetType.ad,
      placementGroup: ContentPlacementGroup.global,
      orderIndex: ValueNumeric(2, fieldName: 'orderIndex'),
      status: ContentStatus.active,
      routeUrl: Url('https://example.com/install'),
      imageUrl: Url('https://cdn.example.com/images/install-ad.png'),
      lastModified: LocalDateTime(DateTime(2026, 7, 10)),
    ),
    ContentAsset(
      id: UniqueId.fromUniqueString('a1b2c3d4-0003'),
      title: ValueString('Profile Completion Native', fieldName: 'title'),
      type: ContentAssetType.native,
      placementGroup: ContentPlacementGroup.account,
      orderIndex: ValueNumeric(1, fieldName: 'orderIndex'),
      status: ContentStatus.active,
      routeUrl: Url('https://example.com/profile'),
      lastModified: LocalDateTime(DateTime(2026, 7, 8)),
    ),
    ContentAsset(
      id: UniqueId.fromUniqueString('a1b2c3d4-0004'),
      title: ValueString('Holiday Campaign Draft', fieldName: 'title'),
      type: ContentAssetType.banner,
      placementGroup: ContentPlacementGroup.home,
      orderIndex: ValueNumeric(3, fieldName: 'orderIndex'),
      status: ContentStatus.draft,
      imageUrl: Url('https://cdn.example.com/images/holiday-draft.jpg'),
      lastModified: LocalDateTime(DateTime(2026, 7, 20)),
    ),
    ContentAsset(
      id: UniqueId.fromUniqueString('a1b2c3d4-0005'),
      title: ValueString('Flash Sale Ad', fieldName: 'title'),
      type: ContentAssetType.ad,
      placementGroup: ContentPlacementGroup.home,
      orderIndex: ValueNumeric(4, fieldName: 'orderIndex'),
      status: ContentStatus.scheduled,
      routeUrl: Url('https://example.com/flash-sale'),
      imageUrl: Url('https://cdn.example.com/images/flash-sale.png'),
      scheduleStart: LocalDateTime(DateTime(2026, 8)),
      scheduleEnd: LocalDateTime(DateTime(2026, 8, 7)),
      lastModified: LocalDateTime(DateTime(2026, 7, 22)),
    ),
    ContentAsset(
      id: UniqueId.fromUniqueString('a1b2c3d4-0006'),
      title: ValueString('Onboarding Native Card', fieldName: 'title'),
      type: ContentAssetType.native,
      placementGroup: ContentPlacementGroup.global,
      orderIndex: ValueNumeric(5, fieldName: 'orderIndex'),
      status: ContentStatus.active,
      routeUrl: Url('https://example.com/onboarding'),
      lastModified: LocalDateTime(DateTime(2026, 6, 30)),
    ),
    ContentAsset(
      id: UniqueId.fromUniqueString('a1b2c3d4-0007'),
      title: ValueString('Referral Program Banner', fieldName: 'title'),
      type: ContentAssetType.banner,
      placementGroup: ContentPlacementGroup.account,
      orderIndex: ValueNumeric(2, fieldName: 'orderIndex'),
      status: ContentStatus.draft,
      imageUrl: Url('https://cdn.example.com/images/referral-banner.jpg'),
      lastModified: LocalDateTime(DateTime(2026, 7, 25)),
    ),
    ContentAsset(
      id: UniqueId.fromUniqueString('a1b2c3d4-0008'),
      title: ValueString('Premium Upgrade Ad', fieldName: 'title'),
      type: ContentAssetType.ad,
      placementGroup: ContentPlacementGroup.account,
      orderIndex: ValueNumeric(3, fieldName: 'orderIndex'),
      status: ContentStatus.scheduled,
      routeUrl: Url('https://example.com/premium'),
      imageUrl: Url('https://cdn.example.com/images/premium-ad.png'),
      scheduleStart: LocalDateTime(DateTime(2026, 8, 15)),
      scheduleEnd: LocalDateTime(DateTime(2026, 9, 15)),
      lastModified: LocalDateTime(DateTime(2026, 7, 28)),
    ),
  ];

  @override
  TaskResult<List<ContentAsset>> listAssets() => TaskEither<Failure, List<ContentAsset>>.tryCatch(() async {
    await Future<void>.delayed(_defaultDelay);
    return List<ContentAsset>.of(_assets);
  }, (Object error, StackTrace _) => Failure.unexpected(error.toString()));

  @override
  TaskResult<ContentAsset?> getAsset(String id) => TaskEither<Failure, ContentAsset?>.tryCatch(() async {
    await Future<void>.delayed(_defaultDelay);
    return _assets.where((ContentAsset a) => a.id.getValue() == id).firstOrNull;
  }, (Object error, StackTrace _) => Failure.unexpected(error.toString()));

  @override
  TaskResult<ContentAsset> saveAsset(ContentAsset asset) => TaskEither<Failure, ContentAsset>.tryCatch(() async {
    await Future<void>.delayed(_saveDelay);
    final int index = _assets.indexWhere((ContentAsset a) => a.id.getValue() == asset.id.getValue());
    if (index >= 0) {
      _assets[index] = asset;
    } else {
      _assets.add(asset);
    }
    return asset;
  }, (Object error, StackTrace _) => Failure.unexpected(error.toString()));

  @override
  TaskResult<Unit> deleteAsset(String id) => TaskEither<Failure, Unit>.tryCatch(() async {
    await Future<void>.delayed(_defaultDelay);
    _assets.removeWhere((ContentAsset a) => a.id.getValue() == id);
    return unit;
  }, (Object error, StackTrace _) => Failure.unexpected(error.toString()));

  @override
  TaskResult<Unit> reorderAssets(List<String> assetIds) => TaskEither<Failure, Unit>.tryCatch(() async {
    await Future<void>.delayed(_defaultDelay);
    return unit;
  }, (Object error, StackTrace _) => Failure.unexpected(error.toString()));

  @override
  TaskResult<Unit> publishAssets(List<ContentAsset> assets) => TaskEither<Failure, Unit>.tryCatch(() async {
    await Future<void>.delayed(_saveDelay);
    return unit;
  }, (Object error, StackTrace _) => Failure.unexpected(error.toString()));

  @override
  TaskResult<Unit> scheduleAssets(List<ContentAsset> assets) => TaskEither<Failure, Unit>.tryCatch(() async {
    await Future<void>.delayed(_saveDelay);
    return unit;
  }, (Object error, StackTrace _) => Failure.unexpected(error.toString()));
}
