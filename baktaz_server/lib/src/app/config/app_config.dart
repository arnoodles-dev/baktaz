/// Application configuration.
abstract final class AppConfig {
  static const Duration defaultTimeout = Duration(minutes: 1);
  static const Duration defaultCacheLifetime = Duration(minutes: 5);

  // OTP Configuration
  static const int otpLength = 6;
  static const Duration otpExpiry = Duration(minutes: 5);
  static const int otpMaxSendsPerHour = 3;
  static const int otpMaxAttemptsPerOtp = 3;
  static const Duration otpRegistrationTokenLifetime = Duration(minutes: 15);
  static const String otpMethod = 'email_otp';

  // Feature Flags
  static const bool accountDeletionEnabled = true;

  // Step Tracking
  static const int maxDailyStepCeiling = 30000;
}
