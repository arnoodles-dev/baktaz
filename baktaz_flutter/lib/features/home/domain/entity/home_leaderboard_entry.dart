import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_leaderboard_entry.freezed.dart';

@freezed
abstract class HomeLeaderboardEntry with _$HomeLeaderboardEntry {
  const factory HomeLeaderboardEntry({
    required Number rank,
    required ValueString username,
    required Number steps,
    required ValueString avgSteps,
    required ValueString trend,
    Url? avatarUrl,
  }) = _HomeLeaderboardEntry;

  const HomeLeaderboardEntry._();

  factory HomeLeaderboardEntry.fromServer(serverpod.HomeLeaderboardEntry model) => HomeLeaderboardEntry(
    rank: Number(model.rank),
    username: ValueString(model.username, fieldName: 'username'),
    steps: Number(model.steps),
    avgSteps: ValueString(model.avgSteps, fieldName: 'avgSteps'),
    trend: ValueString(model.trend, fieldName: 'trend'),
    avatarUrl: model.avatarUrl != null ? Url(model.avatarUrl!.toString()) : null,
  );

  Option<Failure> get validate => rank.validate
      .andThen(() => username.validate)
      .andThen(() => steps.validate)
      .andThen(() => avgSteps.validate)
      .andThen(() => trend.validate)
      .andThen(() => avatarUrl?.validate ?? right(unit))
      .fold(some, (_) => none());
}
