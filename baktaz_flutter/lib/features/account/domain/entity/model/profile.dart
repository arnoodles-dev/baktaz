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

  factory Profile.fromServer(serverpod.UserInfo userInfo) => Profile(
    fullName: ValueName(<String>[
      if (userInfo.firstName case final String first) first,
      if (userInfo.lastName case final String last) last,
    ].join(' ')),
    gender: userInfo.gender,
    birthday: userInfo.birthday.let(LocalDateTime.new),
    updatedAt: userInfo.updatedAt.let(LocalDateTime.new),
    email: userInfo.email.let(EmailAddress.new),
    mobileNumber: userInfo.mobileNumber.let(MobileNumber.new),
  );

  Option<Failure> get validate => fullName.validate
      .andThen(() => email?.validate ?? right(unit))
      .andThen(() => mobileNumber?.validate ?? right(unit))
      .andThen(() => age?.validate ?? right(unit))
      .andThen(() => imageUrl?.validate ?? right(unit))
      .fold(some, (_) => none());
}
