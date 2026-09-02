import 'package:baktaz_server/src/features/account/domain/service/ranking_service.dart';
import 'package:baktaz_server/src/generated/features/account/domain/model/rank.dart';
import 'package:test/test.dart';

void main() {
  group('RankingService', () {
    const Map<String, String> configValues = {
      'ranking.bronze.max': '5000',
      'ranking.silver.max': '8000',
      'ranking.gold.max': '12000',
      'ranking.platinum.max': '15000',
      'ranking.diamond.max': '20000',
    };

    test('returns unknown when avgStepsPerDay is 0', () {
      final service = RankingService(configValues);
      expect(service.computeRank(0), Rank.unknown);
    });

    test('returns unknown when avgStepsPerDay is negative', () {
      final service = RankingService(configValues);
      expect(service.computeRank(-1), Rank.unknown);
    });

    test('returns bronze when avgStepsPerDay is at bronze boundary', () {
      final service = RankingService(configValues);
      expect(service.computeRank(5000), Rank.bronze);
    });

    test('returns silver when avgStepsPerDay is just above bronze', () {
      final service = RankingService(configValues);
      expect(service.computeRank(5001), Rank.silver);
    });

    test('returns silver when avgStepsPerDay is at silver boundary', () {
      final service = RankingService(configValues);
      expect(service.computeRank(8000), Rank.silver);
    });

    test('returns gold when avgStepsPerDay is just above silver', () {
      final service = RankingService(configValues);
      expect(service.computeRank(8001), Rank.gold);
    });

    test('returns gold when avgStepsPerDay is at gold boundary', () {
      final service = RankingService(configValues);
      expect(service.computeRank(12000), Rank.gold);
    });

    test('returns platinum when avgStepsPerDay is just above gold', () {
      final service = RankingService(configValues);
      expect(service.computeRank(12001), Rank.platinum);
    });

    test('returns platinum when avgStepsPerDay is at platinum boundary', () {
      final service = RankingService(configValues);
      expect(service.computeRank(15000), Rank.platinum);
    });

    test('returns diamond when avgStepsPerDay is just above platinum', () {
      final service = RankingService(configValues);
      expect(service.computeRank(15001), Rank.diamond);
    });

    test('returns diamond when avgStepsPerDay is at diamond boundary', () {
      final service = RankingService(configValues);
      expect(service.computeRank(20000), Rank.diamond);
    });

    test('returns challengers when avgStepsPerDay exceeds diamond', () {
      final service = RankingService(configValues);
      expect(service.computeRank(20001), Rank.challengers);
    });

    test('returns unknown when config key is missing', () {
      final service = RankingService(<String, String>{});
      expect(service.computeRank(5000), Rank.unknown);
    });

    test('handles non-numeric config values gracefully', () {
      final service = RankingService({'ranking.bronze.max': 'not_a_number'});
      expect(service.computeRank(5000), Rank.unknown);
    });
  });
}
