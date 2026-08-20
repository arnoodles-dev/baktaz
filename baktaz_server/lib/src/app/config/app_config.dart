class AppConfig {
  static const Duration defaultTimeout = Duration(minutes: 1);
  static const Duration defaultCacheLifetime = Duration(minutes: 5);
}

class OtpConfig {
  static const int length = 6;
  static const Duration expiry = Duration(minutes: 5);
  static const int maxSendsPerHour = 3;
  static const int maxAttemptsPerOtp = 3;
  static const Duration registrationTokenLifetime = Duration(minutes: 15);
  static const String method = 'email_otp';
}
