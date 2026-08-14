enum ContentStatus {
  draft,
  active,
  scheduled;

  String get displayName => switch (this) {
    ContentStatus.draft => 'Draft',
    ContentStatus.active => 'Active',
    ContentStatus.scheduled => 'Scheduled',
  };
}
