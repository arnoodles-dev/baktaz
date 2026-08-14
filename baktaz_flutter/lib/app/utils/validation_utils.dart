import 'package:dartx/dartx.dart';
import 'package:email_validator/email_validator.dart';

final class ValidationUtils {
  ValidationUtils._();

  static String _removeWhiteSpaces(String value) => value.replaceAll(' ', '');

  static String? defaultValidator(String? value) => value.isNullOrBlank ? 'This is a required field' : null;

  static String? mobileNumberValidator(String? value, String phoneMask) {
    final String? initialValidation = defaultValidator(value);
    if (initialValidation != null) {
      return initialValidation;
    }

    /// Note: remove whitespaces(due to phone number masking) before validating
    if (_removeWhiteSpaces(value!).length != _removeWhiteSpaces(phoneMask).length) {
      //TODO: update when intl country code is implemented
      return 'This is not a valid mobile number';
    }

    return null;
  }

  static String? emailValidator(String? value) {
    final String? initialValidation = defaultValidator(value);
    if (initialValidation != null) {
      return initialValidation;
    }
    if (!EmailValidator.validate(value!, true)) {
      return 'This is not a valid email address';
    }

    return null;
  }

  static String? nameValidator(String? value) {
    const int minNameLength = 2;

    const int maxNameLength = 32;
    final RegExp letters = RegExp(r'^[a-zA-Z ]+$');

    final String? initialValidation = defaultValidator(value);
    if (initialValidation != null) {
      return initialValidation;
    }
    if (value == null) {
      return null;
    }
    if (value.startsWith(' ')) {
      return 'Name cannot start with a space';
    }
    if (!letters.hasMatch(value)) {
      return 'Name can only contain letters';
    }

    if (_removeWhiteSpaces(value).length < minNameLength) {
      return 'Name is too short';
    }

    if (_removeWhiteSpaces(value).length > maxNameLength) {
      return 'Name is too long';
    }

    return null;
  }
}
