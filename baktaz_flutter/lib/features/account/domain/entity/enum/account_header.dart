enum AccountHeader {
  myAccount(displayName: 'My Account', options: <String>['profile', 'preferences', 'contacts', 'reviews', 'addresses']),
  support(displayName: 'Support', options: <String>['helpCenter', 'aboutUs', 'privacyPolicy', 'shareFeedback']),
  settings(displayName: 'Settings', options: <String>['language', 'darkMode']);

  const AccountHeader({required this.displayName, required this.options});

  final String displayName;
  final List<String> options;

  static AccountHeader? fromName(String name) =>
      AccountHeader.values.where((AccountHeader h) => h.name == name).firstOrNull;
}
