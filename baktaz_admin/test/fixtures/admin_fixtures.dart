import 'package:baktaz_admin/features/content/domain/entity/content_asset.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_asset_type.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_status.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/dashboard_stats.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/config_snapshot_version.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/config_value_type.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

abstract class AdminFixtures {
  // --- ContentAsset Fixtures ---
  static final ContentAsset contentAssetBanner = ContentAsset(
    id: UniqueId.fromUniqueString('asset_1'),
    title: ValueString('Summer Promo Banner', fieldName: 'title'),
    type: ContentAssetType.banner,
    placementGroup: ContentPlacementGroup.home,
    orderIndex: ValueNumeric(1, fieldName: 'orderIndex'),
    status: ContentStatus.active,
    routeUrl: Url('https://baktaz.com/promo'),
    imageUrl: Url('https://baktaz.com/banner.png'),
    metadataJson: ValueJson(const <String, dynamic>{'campaign': 'summer_2026'}, fieldName: 'metadataJson'),
    scheduleStart: LocalDateTime(DateTime(2026, 6)),
    scheduleEnd: LocalDateTime(DateTime(2026, 8, 31)),
    lastModified: LocalDateTime(DateTime(2026, 5, 15)),
  );

  static final ContentAsset contentAssetDraft = ContentAsset(
    id: UniqueId.fromUniqueString('asset_2'),
    title: ValueString('Draft Popup Ad', fieldName: 'title'),
    type: ContentAssetType.ad,
    placementGroup: ContentPlacementGroup.account,
    orderIndex: ValueNumeric(2, fieldName: 'orderIndex'),
    status: ContentStatus.draft,
  );

  static final List<ContentAsset> contentAssetList = <ContentAsset>[contentAssetBanner, contentAssetDraft];

  // --- RemoteConfigFixtures & RemoteConfigValue / Parameter Fixtures ---
  static final RemoteConfigValue remoteConfigValueBoolean = RemoteConfigValue(
    defaultValue: ConfigDefaultValue(value: ValueBoolean(input: true, fieldName: 'defaultValue')),
    valueType: ConfigValueType.boolean,
    description: ValueString('Enable new checkout flow', fieldName: 'description'),
    lastModified: DateTime(2026, 1, 10),
  );

  static final RemoteConfigValue remoteConfigValueString = RemoteConfigValue(
    defaultValue: ConfigDefaultValue(value: ValueString('v2.4.0', fieldName: 'defaultValue')),
    valueType: ConfigValueType.string,
    description: ValueString('Min supported app version', fieldName: 'description'),
    lastModified: DateTime(2026, 2),
  );

  static final RemoteConfigValue remoteConfigValueNumber = RemoteConfigValue(
    defaultValue: ConfigDefaultValue(value: Number(42)),
    valueType: ConfigValueType.number,
    description: ValueString('Max concurrent upload tasks', fieldName: 'description'),
    lastModified: DateTime(2026, 3, 15),
  );

  static final RemoteConfigValue remoteConfigValueJson = RemoteConfigValue(
    defaultValue: ConfigDefaultValue(value: ValueJson('{"theme": "dark", "rollout": 50}', fieldName: 'defaultValue')),
    valueType: ConfigValueType.json,
    description: ValueString('Feature rollout config', fieldName: 'description'),
    lastModified: DateTime(2026, 4, 20),
  );

  static final RemoteConfig remoteConfigSnapshot = RemoteConfig(
    version: ConfigSnapshotVersion(
      versionNumber: ValueString('v1.0.0', fieldName: 'versionNumber'),
      updateTime: DateTime(2026, 5),
      updateUser: EmailAddress('admin@baktaz.com'),
    ),
    parameters: <String, RemoteConfigValue>{
      'enable_checkout_v2': remoteConfigValueBoolean,
      'min_app_version': remoteConfigValueString,
      'max_upload_tasks': remoteConfigValueNumber,
      'rollout_settings': remoteConfigValueJson,
    },
  );

  // --- DashboardStats Fixtures ---
  static final DashboardStats dashboardStats = DashboardStats(
    totalActivities: Number(1250),
    ongoingActivities: Number(120),
    completedActivities: Number(1130),
    totalRevenue: Money(45200.5),
    totalActivitiesGrowth: '+12.5%',
    ongoingActivitiesGrowth: '+5.0%',
    completedActivitiesGrowth: '+14.2%',
    totalRevenueGrowth: '+18.6%',
  );

  // --- LocalizationKey & Translation Fixtures ---
  static const LocalizationKey localizationKey1 = LocalizationKey(
    id: 1,
    namespace: 'auth',
    key: 'login_title',
    defaultValueEn: 'Welcome Back',
    variables: <String>['username'],
    description: 'Title displayed on login screen',
  );

  static const LocalizationKey localizationKey2 = LocalizationKey(
    id: 2,
    namespace: 'common',
    key: 'button_save',
    defaultValueEn: 'Save',
    description: 'Generic save button label',
  );

  static final List<LocalizationKey> localizationKeyList = <LocalizationKey>[localizationKey1, localizationKey2];

  static const LocalizationTranslation localizationTranslation1 = LocalizationTranslation(
    keyId: 1,
    locale: 'en',
    value: 'Welcome Back',
  );

  static const LocalizationTranslation localizationTranslation2 = LocalizationTranslation(
    keyId: 1,
    locale: 'es',
    value: 'Bienvenido de nuevo',
  );
}
