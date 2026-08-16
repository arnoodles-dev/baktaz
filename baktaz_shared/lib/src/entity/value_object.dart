import 'dart:convert';

import 'package:baktaz_shared/src/entity/failure.dart';
import 'package:baktaz_shared/src/entity/typedef.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trust_but_verify/trust_but_verify.dart';
import 'package:uuid/uuid.dart';

@immutable
abstract class ValueObject<T> {
  const ValueObject();

  @override
  int get hashCode => value.hashCode;

  Result<T> get value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ValueObject<T> && other.value == value;
  }

  Result<Unit> get validate => value.fold(left, (T r) => right(unit));

  T getValue() => value.fold((Failure failure) => throw Exception(failure.message ?? failure.toString()), identity);

  bool get isValid => value.isRight();

  @override
  String toString() => 'Value:$value';
}

class ValueString extends ValueObject<String> {
  factory ValueString(String input, {required String fieldName}) => ValueString._(
    input
        .trust(fieldName)
        .isNotNull()
        .isNotEmpty()
        .verifyEither()
        .fold((ValidationError error) => left(Failure.validation(error, input)), right),
  );

  const ValueString._(this.value);

  @override
  final Result<String> value;
}

class ValueNumeric extends ValueObject<num> {
  factory ValueNumeric(num? input, {required String fieldName, bool isInt = true}) => ValueNumeric._(
    input
        .trust(fieldName)
        .isNotNull()
        .isNonNegative()
        .verifyEither()
        .bind((num value) {
          if (isInt && value is! int) {
            return left<ValidationError, num>(TypeMismatchValidationError(fieldName, 'Value must be an integer'));
          }
          if (!isInt && value is! double) {
            return left<ValidationError, num>(TypeMismatchValidationError(fieldName, 'Value must be a double'));
          }
          return right(value);
        })
        .fold((ValidationError error) => left(Failure.validation(error, input?.toString() ?? '')), right),
  );

  const ValueNumeric._(this.value);

  @override
  final Result<num> value;
}

class UniqueId extends ValueObject<String> {
  factory UniqueId() => UniqueId._(right(const Uuid().v1()));

  factory UniqueId.fromUniqueString(String uniqueId) => UniqueId._(
    uniqueId
        .trust('uuid')
        .isNotEmpty()
        .verifyEither()
        .fold((ValidationError error) => left(Failure.validation(error, uniqueId)), right),
  );

  const UniqueId._(this.value);

  @override
  final Result<String> value;
}

class LocalDateTime {
  factory LocalDateTime(DateTime dateTime) => LocalDateTime._(dateTime.toLocal());

  const LocalDateTime._(this.value);

  final DateTime value;
}

class Url extends ValueObject<String> {
  factory Url(String input) {
    final SyncValidationStep<String> trust = input.trust('url').isNotEmpty();

    // Check if the input is a localhost URL (e.g. http://localhost:8080, http://127.0.0.1, http://10.0.2.2)
    final bool isLocalhost = input.contains('localhost') || input.contains('127.0.0.1') || input.contains('10.0.2.2');
    final SyncValidationStep<String> validator = isLocalhost ? trust : trust.isUrl();

    return Url._(
      validator.verifyEither().fold((ValidationError error) => left(Failure.validation(error, input)), right),
    );
  }

  const Url._(this.value);

  @override
  final Result<String> value;
}

class EmailAddress extends ValueObject<String> {
  factory EmailAddress(String input) => EmailAddress._(
    input
        .trust('email')
        .isNotEmpty()
        .isEmail()
        .verifyEither()
        .fold((ValidationError error) => left(Failure.validation(error, input)), right),
  );

  const EmailAddress._(this.value);

  @override
  final Result<String> value;
}

class Password extends ValueObject<String> {
  factory Password(String input, {bool isHashed = false}) => Password._(
    input
        .trust('password')
        .isNotEmpty()
        .minLength(6) // min password length
        .maxLength(100) // max password length
        .verifyEither()
        .fold(
          (ValidationError error) => left(Failure.validation(error, input)),
          // encrypt password
          (String input) => right(_encryptPassword(input, isHashed: isHashed)),
        ),
  );

  const Password._(this.value);

  @override
  final Result<String> value;

  static String _encryptPassword(String password, {bool isHashed = false}) =>
      isHashed ? sha256.convert(utf8.encode(password)).toString() : password;
}

class Money extends ValueObject<double> {
  factory Money(double input) => Money._(
    input
        .trust('money')
        .isNotNull()
        .isNonNegative()
        .verifyEither()
        .fold((ValidationError error) => left(Failure.validation(error, input.toString())), right),
  );

  const Money._(this.value);

  @override
  final Result<double> value;
}

class MobileNumber extends ValueObject<String> {
  factory MobileNumber(String input) => MobileNumber._(
    input
        .trust('mobile_number')
        .isNotNull()
        .isNotEmpty()
        .isPhone()
        .verifyEither()
        .fold((ValidationError error) => left(Failure.validation(error, input)), right),
  );

  const MobileNumber._(this.value);

  @override
  final Result<String> value;
}

class ValueName extends ValueObject<String> {
  factory ValueName(String input) => ValueName._(
    input
        .trust('name')
        .isNotNull()
        .isNotEmpty()
        .verifyEither()
        .fold((ValidationError error) => left(Failure.validation(error, input)), right),
  );

  const ValueName._(this.value);

  @override
  final Result<String> value;
}

class Number extends ValueObject<num> {
  factory Number(num? input) => Number._(
    input
        .trust('number')
        .isNotNull()
        .isNonNegative()
        .verifyEither()
        .fold((ValidationError error) => left(Failure.validation(error, input?.toString() ?? '')), right),
  );

  const Number._(this.value);

  @override
  final Result<num> value;
}

class ValueBoolean extends ValueObject<bool> {
  factory ValueBoolean({required bool? input, required String fieldName}) => ValueBoolean._(
    input != null
        ? right(input)
        : left(
            Failure.validation(
              TypeMismatchValidationError(fieldName, 'Value must be a boolean'),
              input?.toString() ?? '',
            ),
          ),
  );

  const ValueBoolean._(this.value);

  @override
  final Result<bool> value;
}

class ValueJson extends ValueObject<dynamic> {
  factory ValueJson(dynamic input, {required String fieldName}) => ValueJson._(
    input != null
        ? right(input)
        : left(
            Failure.validation(
              TypeMismatchValidationError(fieldName, 'Value must be valid JSON'),
              input?.toString() ?? '',
            ),
          ),
  );

  const ValueJson._(this.value);

  @override
  final Result<dynamic> value;
}
