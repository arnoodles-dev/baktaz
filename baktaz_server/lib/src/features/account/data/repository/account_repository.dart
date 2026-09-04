import 'package:baktaz_server/src/app/config/app_config.dart';
import 'package:baktaz_server/src/features/account/data/service/ranking_service.dart';
import 'package:baktaz_server/src/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_server/src/features/home/domain/interface/i_challenge_repository.dart';
import 'package:baktaz_server/src/features/remote_config/domain/interface/i_remote_config_repository.dart';
import 'package:baktaz_server/src/features/security/data/service/security_logger.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

@LazySingleton(as: IAccountRepository)
final class AccountRepository implements IAccountRepository {
  AccountRepository(this._securityLogger, this._challengeRepository, this._remoteConfigRepository);

  final SecurityLogger _securityLogger;
  final IChallengeRepository _challengeRepository;
  final IRemoteConfigRepository _remoteConfigRepository;

  @override
  Future<AccountSummary> getAccountSummary(Session session, UuidValue userId) async {
    final List<DailyStepTelemetry> dailySteps = await DailyStepTelemetry.db.find(
      session,
      where: (DailyStepTelemetryTable t) => t.userId.equals(userId),
    );
    final int totalSteps = dailySteps.fold<int>(0, (int sum, DailyStepTelemetry e) => sum + e.currentSteps);
    final int distinctDateCount = dailySteps.map((DailyStepTelemetry e) => e.date).toSet().length;
    final int avgStepsPerDay = distinctDateCount > 0 ? totalSteps ~/ distinctDateCount : 0;

    final RemoteConfig remoteConfig = await _remoteConfigRepository.getPublicConfig(session);
    final Map<String, String> configValues = <String, String>{
      for (final String key in remoteConfig.config.keys) key: remoteConfig.config[key]!.value,
    };
    final Rank rank = RankingService(configValues).computeRank(avgStepsPerDay);

    final ActiveChallengeSummary? activeChallenge = await _challengeRepository.getActiveChallengeSummary(session);
    final int activeChallengeCount = activeChallenge != null ? 1 : 0;

    final UserInfo? userInfo = await UserInfo.db.findFirstRow(
      session,
      where: (UserInfoTable t) => t.userIdentifier.equals(userId),
    );

    final String fullName = <String>[
      if (userInfo?.firstName != null && userInfo!.firstName!.isNotEmpty) userInfo.firstName!,
      if (userInfo?.lastName != null && userInfo!.lastName!.isNotEmpty) userInfo.lastName!,
    ].join(' ').trim();

    return AccountSummary(
      userId: userId,
      isPremium: false,
      totalSteps: totalSteps,
      activeChallengeCount: activeChallengeCount,
      fullName: fullName,
      username: userInfo?.username ?? '',
      challengesJoined: 0,
      challengesWon: 0,
      winRatePercentage: 0,
      isHostTier: false,
      isStepsSyncActive: false,
      memberSince: userInfo?.createdAt,
      avatarUrl: userInfo?.avatarUrl,
      avgStepsPerDay: avgStepsPerDay,
      rank: rank,
    );
  }

  @override
  Future<Account?> getCurrentAccount(Session session, UuidValue userId) => Account.db.findFirstRow(
        session,
        where: (AccountTable t) => t.authUserId.equals(userId),
        include: Account.include(
          userProfile: UserProfile.include(),
          userInfo: UserInfo.include(),
          wallet: Wallet.include(),
        ),
      );

  @override
  Future<void> deleteAccount(Session session, UuidValue userId) async {
    if (!AppConfig.accountDeletionEnabled) {
      throw ApiException(message: 'Account deletion is disabled', code: ApiExceptionCode.badRequest);
    }

    await session.db.transaction((Transaction transaction) async {
      final Account? account = await Account.db.findFirstRow(
        session,
        where: (AccountTable t) => t.authUserId.equals(userId),
        include: Account.include(
          userProfile: UserProfile.include(),
          userInfo: UserInfo.include(),
          wallet: Wallet.include(),
        ),
        transaction: transaction,
      );

      if (account != null) {
        await Account.db.deleteRow(session, account, transaction: transaction);
        if (account.wallet != null) {
          await Wallet.db.deleteRow(session, account.wallet!, transaction: transaction);
        }
        if (account.userInfo != null) {
          await UserInfo.db.deleteRow(session, account.userInfo!, transaction: transaction);
        }
        if (account.userProfile != null) {
          await UserProfile.db.deleteRow(session, account.userProfile!, transaction: transaction);
        }
      }

      final EmailAccount? emailAccount = await EmailAccount.db.findFirstRow(
        session,
        where: (EmailAccountTable t) => t.authUserId.equals(userId),
        transaction: transaction,
      );
      if (emailAccount != null) {
        await EmailAccount.db.deleteRow(session, emailAccount, transaction: transaction);
      }

      await AuthServices.instance.authUsers.delete(session, authUserId: userId, transaction: transaction);
      await _securityLogger.log(session, 'account_delete', authUserId: userId, transaction: transaction);
    });
  }
}
