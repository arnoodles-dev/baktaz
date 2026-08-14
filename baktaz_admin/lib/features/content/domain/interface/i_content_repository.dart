import 'package:baktaz_admin/features/content/domain/entity/content_asset.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class IContentRepository {
  TaskResult<List<ContentAsset>> listAssets();
  TaskResult<ContentAsset?> getAsset(String id);
  TaskResult<ContentAsset> saveAsset(ContentAsset asset);
  TaskResult<Unit> deleteAsset(String id);
  TaskResult<Unit> reorderAssets(List<String> assetIds);
  TaskResult<Unit> publishAssets(List<ContentAsset> assets);
  TaskResult<Unit> scheduleAssets(List<ContentAsset> assets);
}
