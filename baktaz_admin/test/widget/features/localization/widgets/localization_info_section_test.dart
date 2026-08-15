import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_info_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(LocalizationInfoSection, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'localization_info_section'.goldensVersion,
      builder: () => const MockMaterialApp(
        surfaceWidth: 1400,
        child: SizedBox(width: 1400, height: 400, child: LocalizationInfoSection()),
      ),
    );
  });
}
