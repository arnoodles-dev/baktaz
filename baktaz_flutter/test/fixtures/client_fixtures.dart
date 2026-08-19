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
  name: 'John Doe',
  cashBalance: 250.75,
  connectBalance: 100,
  imageUrl: Uri.parse('https://example.com/avatar.png'),
);

final AccountSummary mockAccountSummary = AccountSummary.fromServer(mockServerAccountSummary);

final serverpod.AccountSummary mockServerAccountSummaryNullUrl = serverpod.AccountSummary(
  name: 'Jane Doe',
  cashBalance: 0,
  connectBalance: 0,
);

final AccountSummary mockAccountSummaryNullUrl = AccountSummary.fromServer(mockServerAccountSummaryNullUrl);

final serverpod.Profile mockServerProfile = serverpod.Profile(
  fullName: 'John Doe',
  gender: serverpod.Gender.male,
  email: 'john.doe@baktaz.com',
  mobileNumber: '+1234567890',
  age: 28,
  birthday: DateTime(1998, 5, 15),
  imageUrl: Uri.parse('https://example.com/avatar.png'),
);

final Profile mockProfile = Profile.fromServer(mockServerProfile);

final Profile mockEmptyProfile = Profile(fullName: ValueName('Unnamed User'), gender: serverpod.Gender.unknown);

final serverpod.UserInfo mockUserInfo = serverpod.UserInfo(
  id: UuidValue.fromString('00000000-0000-0000-0000-000000000002'),
  gender: serverpod.Gender.male,
  birthday: DateTime(1998, 5, 15),
  mobileNumber: '+1234567890',
);
