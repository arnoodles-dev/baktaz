import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/profile/data/repository/profile_repository.dart';
import 'package:baktaz_server/src/features/profile/domain/interface/i_profile_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:get_it/get_it.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../../../integration/test_tools/serverpod_test_tools.dart';

void main() {
  if (!GetIt.I.isRegistered<IProfileRepository>()) {
    configureDependencies();
  }

  withServerpod(
    'Given ProfileRepository',
    (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
      late ProfileRepository repository;

      setUp(() {
        repository = ProfileRepository();
      });

      group('getUserInfo', () {
        test('returns null when user does not exist', () async {
          final Session session = sessionBuilder.build();
          final UuidValue nonExistentId = UuidValue.fromString('00000000-0000-4000-8000-000000000001');

          final UserInfo? user = await repository.getUserInfo(session, nonExistentId);
          expect(user, isNull);
        });

        test('returns UserInfo matching userIdentifier', () async {
          final Session session = sessionBuilder.build();
          final UuidValue userId = UuidValue.fromString('11111111-1111-4111-8111-111111111111');

          await UserInfo.db.insertRow(
            session,
            UserInfo(
              userIdentifier: userId,
              email: 'testuser@example.com',
              username: 'testuser',
              firstName: 'Test',
              lastName: 'User',
              createdAt: DateTime.now(),
            ),
          );

          final UserInfo? fetched = await repository.getUserInfo(session, userId);
          expect(fetched, isNotNull);
          expect(fetched?.userIdentifier, equals(userId));
          expect(fetched?.username, equals('testuser'));
        });
      });

      group('isUsernameAvailable', () {
        test('returns true when username is not taken', () async {
          final Session session = sessionBuilder.build();
          final bool available = await repository.isUsernameAvailable(session, 'new_unique_user');
          expect(available, isTrue);
        });

        test('returns false when username is already taken', () async {
          final Session session = sessionBuilder.build();
          final UuidValue userId = UuidValue.fromString('22222222-2222-4222-8222-222222222222');

          await UserInfo.db.insertRow(
            session,
            UserInfo(
              userIdentifier: userId,
              email: 'existing@example.com',
              username: 'existinguser',
              createdAt: DateTime.now(),
            ),
          );

          final bool available = await repository.isUsernameAvailable(session, 'existinguser');
          expect(available, isFalse);
        });
      });

      group('updateProfile', () {
        test('updates firstName, lastName, and username successfully', () async {
          final Session session = sessionBuilder.build();
          final UuidValue userId = UuidValue.fromString('33333333-3333-4333-8333-333333333333');

          await UserInfo.db.insertRow(
            session,
            UserInfo(
              userIdentifier: userId,
              email: 'update_me@example.com',
              username: 'oldusername',
              firstName: 'OldFirst',
              lastName: 'OldLast',
              createdAt: DateTime.now(),
            ),
          );

          final UserInfo? updated = await repository.updateProfile(
            session,
            userId,
            'NewFirst',
            'NewLast',
            'newusername',
          );

          expect(updated, isNotNull);
          expect(updated?.firstName, equals('NewFirst'));
          expect(updated?.lastName, equals('NewLast'));
          expect(updated?.username, equals('newusername'));
        });

        test('throws ApiException when profile not found', () async {
          final Session session = sessionBuilder.build();
          final UuidValue nonExistentId = UuidValue.fromString('00000000-0000-4000-8000-000000000999');

          expect(
            () => repository.updateProfile(session, nonExistentId, 'Jane', 'Doe', 'janedoe'),
            throwsA(
              isA<ApiException>()
                  .having((ApiException e) => e.code, 'code', ApiExceptionCode.notFound)
                  .having((ApiException e) => e.message, 'message', 'User profile not found'),
            ),
          );
        });

        test('throws ApiException when username is already taken by another user', () async {
          final Session session = sessionBuilder.build();
          final UuidValue user1Id = UuidValue.fromString('44444444-4444-4444-8444-444444444444');
          final UuidValue user2Id = UuidValue.fromString('55555555-5555-4555-8555-555555555555');

          await UserInfo.db.insertRow(
            session,
            UserInfo(
              userIdentifier: user1Id,
              email: 'taken@example.com',
              username: 'takenusername',
              createdAt: DateTime.now(),
            ),
          );

          await UserInfo.db.insertRow(
            session,
            UserInfo(
              userIdentifier: user2Id,
              email: 'updater@example.com',
              username: 'myusername',
              createdAt: DateTime.now(),
            ),
          );

          expect(
            () => repository.updateProfile(session, user2Id, null, null, 'takenusername'),
            throwsA(
              isA<ApiException>()
                  .having((ApiException e) => e.code, 'code', ApiExceptionCode.badRequest)
                  .having((ApiException e) => e.message, 'message', 'Username is already taken'),
            ),
          );
        });
      });
    },
    applyMigrations: true,
  );
}
