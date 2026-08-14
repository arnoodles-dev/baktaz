enum ContentAssetType {
  banner,
  ad,
  native;

  String get displayName => switch (this) {
    ContentAssetType.banner => 'Banner',
    ContentAssetType.ad => 'Ad',
    ContentAssetType.native => 'Native',
  };
}
