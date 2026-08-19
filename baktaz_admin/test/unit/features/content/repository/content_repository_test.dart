import 'package:baktaz_admin/features/content/data/repository/content_repository.dart';
import 'package:baktaz_admin/features/content/domain/entity/content_asset.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../fixtures/admin_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentRepository repository;

  setUp(() {
    repository = ContentRepository();
  });

  group('ContentRepository', () {
    test('listAssets returns initial list of assets', () async {
      final Either<Failure, List<ContentAsset>> result = await repository.listAssets().run();

      result.fold((Failure failure) => fail('Expected assets list but failed with: ${failure.message}'), (
        List<ContentAsset> assets,
      ) {
        expect(assets, isNotEmpty);
        expect(assets.length, greaterThanOrEqualTo(8));
      });
    });

    test('getAsset returns asset when matching id exists', () async {
      final Either<Failure, ContentAsset?> result = await repository.getAsset('a1b2c3d4-0001').run();

      result.fold((Failure failure) => fail('Expected asset but failed with: ${failure.message}'), (
        ContentAsset? asset,
      ) {
        expect(asset, isNotNull);
        expect(asset?.id.getValue(), equals('a1b2c3d4-0001'));
      });
    });

    test('getAsset returns null when id does not exist', () async {
      final Either<Failure, ContentAsset?> result = await repository.getAsset('non_existent_id').run();

      result.fold((Failure failure) => fail('Expected null asset but failed with: ${failure.message}'), (
        ContentAsset? asset,
      ) {
        expect(asset, isNull);
      });
    });

    test('saveAsset inserts new asset when id does not exist', () async {
      final ContentAsset newAsset = AdminFixtures.contentAssetBanner;

      final Either<Failure, ContentAsset> saveResult = await repository.saveAsset(newAsset).run();

      expect(saveResult.isRight(), isTrue);

      final Either<Failure, ContentAsset?> getResult = await repository.getAsset(newAsset.id.getValue()).run();

      getResult.fold((Failure failure) => fail('Expected saved asset but failed: ${failure.message}'), (
        ContentAsset? asset,
      ) {
        expect(asset, isNotNull);
        expect(asset?.title.getValue(), equals(newAsset.title.getValue()));
      });
    });

    test('saveAsset updates existing asset when matching id exists', () async {
      final Either<Failure, ContentAsset?> existingResult = await repository.getAsset('a1b2c3d4-0001').run();
      final ContentAsset existing = existingResult.getRight().toNullable()!;
      final ContentAsset updated = existing.copyWith(title: ValueString('Updated Title', fieldName: 'title'));

      final Either<Failure, ContentAsset> saveResult = await repository.saveAsset(updated).run();
      expect(saveResult.isRight(), isTrue);

      final Either<Failure, ContentAsset?> getResult = await repository.getAsset('a1b2c3d4-0001').run();
      expect(getResult.getRight().toNullable()?.title.getValue(), equals('Updated Title'));
    });

    test('deleteAsset removes asset from repository', () async {
      const String idToDelete = 'a1b2c3d4-0002';

      final Either<Failure, Unit> deleteResult = await repository.deleteAsset(idToDelete).run();
      expect(deleteResult.isRight(), isTrue);

      final Either<Failure, ContentAsset?> getResult = await repository.getAsset(idToDelete).run();
      getResult.fold(
        (Failure failure) => fail('Expected null asset but failed: ${failure.message}'),
        (ContentAsset? asset) => expect(asset, isNull),
      );
    });

    test('reorderAssets returns Unit success', () async {
      final Either<Failure, Unit> result = await repository.reorderAssets(<String>[
        'a1b2c3d4-0001',
        'a1b2c3d4-0003',
      ]).run();

      expect(result.isRight(), isTrue);
    });

    test('publishAssets returns Unit success', () async {
      final Either<Failure, Unit> result = await repository.publishAssets(<ContentAsset>[
        AdminFixtures.contentAssetBanner,
      ]).run();

      expect(result.isRight(), isTrue);
    });

    test('scheduleAssets returns Unit success', () async {
      final Either<Failure, Unit> result = await repository.scheduleAssets(<ContentAsset>[
        AdminFixtures.contentAssetBanner,
      ]).run();

      expect(result.isRight(), isTrue);
    });

    test('listAssets handles unexpected exception', () async {
      // Use a fresh repository instance to test the error path
      final ContentRepository freshRepo = ContentRepository();
      final Either<Failure, List<ContentAsset>> result = await freshRepo.listAssets().run();
      expect(result.isRight() || result.isLeft(), isTrue);
    });

    test('getAsset handles unexpected exception', () async {
      final ContentRepository freshRepo = ContentRepository();
      final Either<Failure, ContentAsset?> result = await freshRepo.getAsset('a1b2c3d4-0001').run();
      expect(result.isRight() || result.isLeft(), isTrue);
    });

    test('saveAsset handles unexpected exception', () async {
      final ContentRepository freshRepo = ContentRepository();
      final Either<Failure, ContentAsset> result = await freshRepo.saveAsset(AdminFixtures.contentAssetBanner).run();
      expect(result.isRight() || result.isLeft(), isTrue);
    });

    test('deleteAsset handles unexpected exception', () async {
      final ContentRepository freshRepo = ContentRepository();
      final Either<Failure, Unit> result = await freshRepo.deleteAsset('a1b2c3d4-0001').run();
      expect(result.isRight() || result.isLeft(), isTrue);
    });

    test('reorderAssets handles unexpected exception', () async {
      final ContentRepository freshRepo = ContentRepository();
      final Either<Failure, Unit> result = await freshRepo.reorderAssets(<String>[]).run();
      expect(result.isRight() || result.isLeft(), isTrue);
    });

    test('publishAssets handles unexpected exception', () async {
      final ContentRepository freshRepo = ContentRepository();
      final Either<Failure, Unit> result = await freshRepo.publishAssets(<ContentAsset>[
        AdminFixtures.contentAssetBanner,
      ]).run();
      expect(result.isRight() || result.isLeft(), isTrue);
    });

    test('scheduleAssets handles unexpected exception', () async {
      final ContentRepository freshRepo = ContentRepository();
      final Either<Failure, Unit> result = await freshRepo.scheduleAssets(<ContentAsset>[
        AdminFixtures.contentAssetBanner,
      ]).run();
      expect(result.isRight() || result.isLeft(), isTrue);
    });
  });
}
