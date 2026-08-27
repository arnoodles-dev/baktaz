import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

abstract final class SharedFixtures {
  static const String sampleText = 'Hello Test';
  static const String sampleMarkdownText = '# Heading\n\nThis is **bold** text.';
  static const String sampleStyledText =
      'Hello <b>bold</b> and <blueText>blue</blueText> user! <link href="action">Click here</link>';
  static const String imageUrl = 'https://example.com/avatar.png';
  static const String initials = 'TU';

  static const Failure unexpectedFailure = Failure.unexpected('Something went wrong');
  static const Failure serverFailure = Failure.server(StatusCode.http500, 'Server error');
  static const Failure serverpodFailure = Failure.server(StatusCode.serverpod, 'Serverpod error');

  static final ResourceErrorDTO resourceError = ResourceErrorDTO('type', 'message');

  static final PhoneCountryData phCountryData = PhoneCodes.getPhoneCountryDataByCountryCode('PH')!;
  static final PhoneCountryData usCountryData = PhoneCodes.getPhoneCountryDataByCountryCode('US')!;
}
