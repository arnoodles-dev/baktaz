import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/config_snapshot_version.dart';
import 'package:baktaz_admin/features/remote_config/presentation/widgets/config_info_section.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';

void main() {
  group('ConfigInfoSection Golden Tests', () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'config_info_section',
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'with data',
            child: MockMaterialApp(
              child: ConfigInfoSection(
                version: ConfigSnapshotVersion(
                  versionNumber: ValueString('1.2.3', fieldName: 'versionNumber'),
                  updateTime: DateTime(2026),
                  updateUser: EmailAddress('admin@baktaz.com'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
