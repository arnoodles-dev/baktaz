enum AccountHeader {
  myAccount(displayName: 'My Account', options: <String>['profile', 'contacts', 'reviews']),
  support(displayName: 'Support', options: <String>['helpCenter', 'aboutUs', 'privacyPolicy']),
  settings(displayName: 'Settings', options: <String>['darkMode']);

  const AccountHeader({required this.displayName, required this.options});

  final String displayName;
  final List<String> options;

  static AccountHeader fromName(String name) {
    final AccountHeader? result =
        AccountHeader.values.where((AccountHeader h) => h.name == name).firstOrNull;
    if (result == null) {
      throw ArgumentError('Unknown AccountHeader name: $name');
    }
    return result;
  }
}
