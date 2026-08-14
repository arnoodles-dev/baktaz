import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/domain/entity/paginated_response.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ILocalizationRepository {
  TaskResult<PaginatedResponse<LocalizationKey>> getKeys({
    required int page,
    required int limit,
    required String sortField,
    required bool ascending,
  });

  TaskResult<Unit> publishTranslations(List<LocalizationTranslation> translations);
}
