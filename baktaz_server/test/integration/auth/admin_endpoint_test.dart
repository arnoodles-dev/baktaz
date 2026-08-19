// ignore_for_file: no-empty-block

import 'package:baktaz_server/src/features/auth/domain/interface/i_admin_repository.dart';
import 'package:baktaz_server/src/features/auth/endpoint/admin_endpoint.dart';
import 'package:mockito/mockito.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import '../../fixtures/server_fixtures.dart';
import '../../utils/generated_mocks.mocks.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given AdminEndpoint', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
    group('when unauthenticated', () {
      final TestSessionBuilder unauthedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.unauthenticated(),
      );

      test('then listAdminUsers throws ServerpodUnauthenticatedException', () async {
        await expectLater(
          endpoints.admin.listAdminUsers(unauthedSession),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('then listAuthUsers throws ServerpodUnauthenticatedException', () async {
        await expectLater(
          endpoints.admin.listAuthUsers(unauthedSession),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('then blockUser throws ServerpodUnauthenticatedException', () async {
        await expectLater(
          endpoints.admin.blockUser(unauthedSession, ServerFixtures.testAuthUserId),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('then unblockUser throws ServerpodUnauthenticatedException', () async {
        await expectLater(
          endpoints.admin.unblockUser(unauthedSession, ServerFixtures.testAuthUserId),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('then updateUserScope throws ServerpodUnauthenticatedException', () async {
        await expectLater(
          endpoints.admin.updateUserScope(unauthedSession, ServerFixtures.testAuthUserId, <String>['admin']),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });
    });

    group('when authenticated as non-admin user', () {
      final TestSessionBuilder nonAdminSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ServerFixtures.testAuthUserId.toString(),
          ServerFixtures.userScopes,
        ),
      );

      test('then listAdminUsers throws access exception due to missing admin scope', () async {
        await expectLater(
          endpoints.admin.listAdminUsers(nonAdminSession),
          throwsA(anyOf(isA<ServerpodInsufficientAccessException>(), isA<ServerpodUnauthenticatedException>())),
        );
      });

      test('then listAuthUsers throws access exception due to missing admin scope', () async {
        await expectLater(
          endpoints.admin.listAuthUsers(nonAdminSession),
          throwsA(anyOf(isA<ServerpodInsufficientAccessException>(), isA<ServerpodUnauthenticatedException>())),
        );
      });

      test('then blockUser throws access exception due to missing admin scope', () async {
        await expectLater(
          endpoints.admin.blockUser(nonAdminSession, ServerFixtures.testAuthUserId),
          throwsA(anyOf(isA<ServerpodInsufficientAccessException>(), isA<ServerpodUnauthenticatedException>())),
        );
      });

      test('then unblockUser throws access exception due to missing admin scope', () async {
        await expectLater(
          endpoints.admin.unblockUser(nonAdminSession, ServerFixtures.testAuthUserId),
          throwsA(anyOf(isA<ServerpodInsufficientAccessException>(), isA<ServerpodUnauthenticatedException>())),
        );
      });

      test('then updateUserScope throws access exception due to missing admin scope', () async {
        await expectLater(
          endpoints.admin.updateUserScope(nonAdminSession, ServerFixtures.testAuthUserId, <String>['admin']),
          throwsA(anyOf(isA<ServerpodInsufficientAccessException>(), isA<ServerpodUnauthenticatedException>())),
        );
      });
    });

    group('when authenticated as admin user', () {
      final TestSessionBuilder adminSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ServerFixtures.testAdminAuthUserId.toString(),
          ServerFixtures.adminScopes,
        ),
      );

      test('then listAdminUsers delegates to repository and returns list', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(mockRepo.listAdminUsers(session))
            .thenAnswer((Invocation _) async => <AdminUser>[ServerFixtures.adminAdminUserRecord]);

        final List<AdminUser> result = await customAdminEndpoint.listAdminUsers(session);

        expect(result, hasLength(1));
        expect(result.first.userProfile.email, equals('admin@baktaz.com'));
        verify(mockRepo.listAdminUsers(session)).called(1);
      });

      test('then listAdminUsers returns empty list when repository has no admins', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(mockRepo.listAdminUsers(session)).thenAnswer((Invocation _) async => <AdminUser>[]);

        final List<AdminUser> result = await customAdminEndpoint.listAdminUsers(session);

        expect(result, isEmpty);
        verify(mockRepo.listAdminUsers(session)).called(1);
      });

      test('then listAdminUsers rethrows repository exception', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(mockRepo.listAdminUsers(session)).thenThrow(Exception('DB failure'));

        await expectLater(
          customAdminEndpoint.listAdminUsers(session),
          throwsA(isA<Exception>().having((Exception e) => e.toString(), 'message', contains('DB failure'))),
        );
      });

      test('then listAuthUsers delegates to repository and returns list', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(mockRepo.listAuthUsers(session)).thenAnswer(
          (Invocation _) async => <AuthUserModel>[ServerFixtures.sampleAuthUser, ServerFixtures.adminAuthUser],
        );

        final List<AuthUserModel> result = await customAdminEndpoint.listAuthUsers(session);

        expect(result, hasLength(2));
        verify(mockRepo.listAuthUsers(session)).called(1);
      });

      test('then listAuthUsers returns empty list when repository has no users', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(mockRepo.listAuthUsers(session)).thenAnswer((Invocation _) async => <AuthUserModel>[]);

        final List<AuthUserModel> result = await customAdminEndpoint.listAuthUsers(session);

        expect(result, isEmpty);
        verify(mockRepo.listAuthUsers(session)).called(1);
      });

      test('then listAuthUsers rethrows repository exception', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(mockRepo.listAuthUsers(session)).thenThrow(Exception('DB failure'));

        await expectLater(
          customAdminEndpoint.listAuthUsers(session),
          throwsA(isA<Exception>().having((Exception e) => e.toString(), 'message', contains('DB failure'))),
        );
      });

      test('then blockUser delegates to repository', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(mockRepo.blockUser(session, ServerFixtures.testAuthUserId)).thenAnswer((Invocation _) async {});

        await customAdminEndpoint.blockUser(session, ServerFixtures.testAuthUserId);

        verify(mockRepo.blockUser(session, ServerFixtures.testAuthUserId)).called(1);
      });

      test('then blockUser rethrows repository exception', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(mockRepo.blockUser(session, ServerFixtures.testAuthUserId)).thenThrow(Exception('User not found'));

        await expectLater(
          customAdminEndpoint.blockUser(session, ServerFixtures.testAuthUserId),
          throwsA(isA<Exception>().having((Exception e) => e.toString(), 'message', contains('User not found'))),
        );
      });

      test('then unblockUser delegates to repository', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(mockRepo.unblockUser(session, ServerFixtures.testAuthUserId)).thenAnswer((Invocation _) async {});

        await customAdminEndpoint.unblockUser(session, ServerFixtures.testAuthUserId);

        verify(mockRepo.unblockUser(session, ServerFixtures.testAuthUserId)).called(1);
      });

      test('then unblockUser rethrows repository exception', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(mockRepo.unblockUser(session, ServerFixtures.testAuthUserId)).thenThrow(Exception('User not found'));

        await expectLater(
          customAdminEndpoint.unblockUser(session, ServerFixtures.testAuthUserId),
          throwsA(isA<Exception>().having((Exception e) => e.toString(), 'message', contains('User not found'))),
        );
      });

      test('then updateUserScope throws Exception when scopeNames is empty', () async {
        await expectLater(
          endpoints.admin.updateUserScope(adminSession, ServerFixtures.testAuthUserId, <String>[]),
          throwsA(
            isA<Exception>().having(
              (Exception e) => e.toString(),
              'message',
              contains('Scope names list cannot be empty'),
            ),
          ),
        );
      });

      test('then updateUserScope delegates to repository when scopes are valid', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(mockRepo.updateUserScope(session, ServerFixtures.testAuthUserId, argThat(contains(Scope.admin))))
            .thenAnswer((Invocation _) async {});

        await customAdminEndpoint.updateUserScope(session, ServerFixtures.testAuthUserId, <String>['admin']);

        verify(mockRepo.updateUserScope(session, ServerFixtures.testAuthUserId, argThat(contains(Scope.admin))))
            .called(1);
      });

      test('then updateUserScope maps multiple scope names to scopes', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(
          mockRepo.updateUserScope(
            session,
            ServerFixtures.testAuthUserId,
            argThat(equals(ServerFixtures.customScopes)),
          ),
        ).thenAnswer((Invocation _) async {});

        await customAdminEndpoint.updateUserScope(session, ServerFixtures.testAuthUserId, <String>['user', 'custom']);

        verify(
          mockRepo.updateUserScope(
            session,
            ServerFixtures.testAuthUserId,
            argThat(equals(ServerFixtures.customScopes)),
          ),
        ).called(1);
      });

      test('then updateUserScope rethrows repository exception', () async {
        final MockIAdminRepository mockRepo = MockIAdminRepository();
        final AdminEndpoint customAdminEndpoint = AdminEndpoint(mockRepo);
        final Session session = adminSession.build();

        when(mockRepo.updateUserScope(session, ServerFixtures.testAuthUserId, argThat(contains(Scope.admin))))
            .thenThrow(Exception('Invalid scope'));

        await expectLater(
          customAdminEndpoint.updateUserScope(session, ServerFixtures.testAuthUserId, <String>['admin']),
          throwsA(isA<Exception>().having((Exception e) => e.toString(), 'message', contains('Invalid scope'))),
        );
      });
    });
  });
}
