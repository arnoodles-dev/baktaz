import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

final AuthSuccess mockAuthSuccess = AuthSuccess(
  authStrategy: 'email',
  token: 'mock_auth_token_12345',
  authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
  scopeNames: const <String>{'user'},
);

final AuthSuccess mockExpiredAuthSuccess = AuthSuccess(
  authStrategy: 'email',
  token: '',
  authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
  scopeNames: const <String>{},
);

final serverpod.AccountSummary mockServerAccountSummary = serverpod.AccountSummary(
  userId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
  isPremium: true,
  totalSteps: 12500,
  activeChallengeCount: 2,
  fullName: 'John Doe',
  username: 'johndoe',
  avatarUrl: 'https://example.com/avatar.png',
  challengesJoined: 10,
  challengesWon: 5,
  winRatePercentage: 50,
);

final AccountSummary mockAccountSummary = AccountSummary.fromServer(mockServerAccountSummary);

final serverpod.AccountSummary mockServerAccountSummaryNonPremium = serverpod.AccountSummary(
  userId: UuidValue.fromString('00000000-0000-0000-0000-000000000002'),
  isPremium: false,
  totalSteps: 0,
  activeChallengeCount: 0,
  fullName: 'Jane Doe',
  username: 'janedoe',
  challengesJoined: 0,
  challengesWon: 0,
  winRatePercentage: 0,
);

final AccountSummary mockAccountSummaryNonPremium = AccountSummary.fromServer(mockServerAccountSummaryNonPremium);

final serverpod.UserInfo mockServerProfile = serverpod.UserInfo(
  userIdentifier: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
  email: 'john.doe@baktaz.com',
  username: 'johndoe',
  firstName: 'John',
  lastName: 'Doe',
  gender: serverpod.Gender.male,
  birthday: DateTime(1998, 5, 15),
  mobileNumber: '+1234567890',
);

final Profile mockProfile = Profile.fromServer(mockServerProfile);

final Profile mockEmptyProfile = Profile(fullName: ValueName('Unnamed User'), gender: serverpod.Gender.unknown);

final serverpod.UserInfo mockUserInfo = serverpod.UserInfo(
  id: UuidValue.fromString('00000000-0000-0000-0000-000000000002'),
  userIdentifier: UuidValue.fromString('00000000-0000-0000-0000-000000000002'),
  email: 'test@baktaz.com',
  username: 'testuser',
  gender: serverpod.Gender.male,
  birthday: DateTime(1998, 5, 15),
  mobileNumber: '+1234567890',
);
