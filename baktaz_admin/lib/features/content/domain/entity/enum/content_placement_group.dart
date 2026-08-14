enum ContentPlacementGroup {
  home,
  account,
  global;

  String get displayName => switch (this) {
    ContentPlacementGroup.home => 'Home',
    ContentPlacementGroup.account => 'Account',
    ContentPlacementGroup.global => 'Global',
  };
}
