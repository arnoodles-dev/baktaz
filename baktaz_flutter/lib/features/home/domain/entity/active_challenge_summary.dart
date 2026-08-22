import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'active_challenge_summary.freezed.dart';

@freezed
abstract class ActiveChallengeSummary with _$ActiveChallengeSummary {
  const factory ActiveChallengeSummary({
    required ValueBoolean isEnrolled,
    ValueString? title,
    Number? rank,
    Number? totalParticipants,
    ValueString? prizePoolText,
    ValueString? gapText,
    List<ValueString>? leaders,
    Number? currentDay,
    Number? totalDays,
  }) = _ActiveChallengeSummary;

  const ActiveChallengeSummary._();

  factory ActiveChallengeSummary.fromServer(serverpod.ActiveChallengeSummary model) => ActiveChallengeSummary(
    isEnrolled: ValueBoolean(input: model.isEnrolled, fieldName: 'isEnrolled'),
    title: model.title != null ? ValueString(model.title!, fieldName: 'title') : null,
    rank: model.rank != null ? Number(model.rank) : null,
    totalParticipants: model.totalParticipants != null ? Number(model.totalParticipants) : null,
    prizePoolText: model.prizePoolText != null ? ValueString(model.prizePoolText!, fieldName: 'prizePoolText') : null,
    gapText: model.gapText != null ? ValueString(model.gapText!, fieldName: 'gapText') : null,
    leaders: model.leaders?.map((String l) => ValueString(l, fieldName: 'leader')).toList(),
    currentDay: model.currentDay != null ? Number(model.currentDay) : null,
    totalDays: model.totalDays != null ? Number(model.totalDays) : null,
  );

  Option<Failure> get validate => isEnrolled.validate
      .andThen(() => title?.validate ?? right(unit))
      .andThen(() => rank?.validate ?? right(unit))
      .fold(some, (_) => none());
}
