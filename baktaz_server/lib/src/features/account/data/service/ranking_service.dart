import 'package:baktaz_server/src/generated/features/account/domain/model/rank.dart';

final class RankingService {
  RankingService(this.configValues);

  final Map<String, String> configValues;

  Rank computeRank(int avgStepsPerDay) {
    if (avgStepsPerDay <= 0) return Rank.unknown;
    final int bronzeMax = _parseInt('ranking.bronze.max');
    final int silverMax = _parseInt('ranking.silver.max');
    final int goldMax = _parseInt('ranking.gold.max');
    final int platinumMax = _parseInt('ranking.platinum.max');
    final int diamondMax = _parseInt('ranking.diamond.max');
    // If no thresholds are configured, default to unknown
    if (bronzeMax <= 0 && silverMax <= 0 && goldMax <= 0 && platinumMax <= 0 && diamondMax <= 0) {
      return Rank.unknown;
    }
    if (avgStepsPerDay <= bronzeMax) return Rank.bronze;
    if (avgStepsPerDay <= silverMax) return Rank.silver;
    if (avgStepsPerDay <= goldMax) return Rank.gold;
    if (avgStepsPerDay <= platinumMax) return Rank.platinum;
    if (avgStepsPerDay <= diamondMax) return Rank.diamond;
    return Rank.challengers;
  }

  int _parseInt(String key) {
    final String? value = configValues[key];
    if (value == null) return 0;
    return int.tryParse(value) ?? 0;
  }
}
