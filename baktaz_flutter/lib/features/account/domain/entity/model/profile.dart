import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required ValueName fullName,
    required serverpod.Gender gender,
    EmailAddress? email,
    MobileNumber? mobileNumber,
    LocalDateTime? birthday,
    Number? age,
    Url? imageUrl,
    LocalDateTime? updatedAt,
  }) = _Profile;

  const Profile._();

  factory Profile.fromServer(serverpod.Profile profile) => Profile(
    fullName: ValueName(profile.fullName),
    gender: profile.gender,
    birthday: profile.birthday.let(LocalDateTime.new),
    age: profile.age.let(Number.new),
    imageUrl: profile.imageUrl.let((Uri uri) => Url(uri.toString())),
    updatedAt: profile.updatedAt.let(LocalDateTime.new),
    email: profile.email.let(EmailAddress.new),
    mobileNumber: profile.mobileNumber.let(MobileNumber.new),
  );

  Option<Failure> get validate => fullName.validate
      .andThen(() => email?.validate ?? right(unit))
      .andThen(() => mobileNumber?.validate ?? right(unit))
      .andThen(() => age?.validate ?? right(unit))
      .andThen(() => imageUrl?.validate ?? right(unit))
      .fold(some, (_) => none());
}
