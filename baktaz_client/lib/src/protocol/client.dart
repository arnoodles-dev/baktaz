/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:baktaz_client/src/protocol/features/account/domain/model/account.dart'
    as _i3;
import 'package:baktaz_client/src/protocol/features/account/domain/model/account_summary.dart'
    as _i4;
import 'package:baktaz_client/src/protocol/features/account/domain/model/profile.dart'
    as _i5;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i6;
import 'package:baktaz_client/src/protocol/features/auth/domain/models/otp_verification_result.dart'
    as _i7;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i8;
import 'package:baktaz_client/src/protocol/features/security/domain/models/security_event.dart'
    as _i9;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i10;
import 'package:http/http.dart' as _i11;
import 'protocol.dart' as _i12;

/// {@category Endpoint}
abstract class EndpointAdminEndpointBase extends _i1.EndpointRef {
  EndpointAdminEndpointBase(_i1.EndpointCaller caller) : super(caller);
}

/// {@category Endpoint}
class EndpointAccount extends _i1.EndpointRef {
  EndpointAccount(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'account';

  _i2.Future<_i3.Account?> getCurrentAccount() =>
      caller.callServerEndpoint<_i3.Account?>(
        'account',
        'getCurrentAccount',
        {},
      );

  _i2.Future<_i4.AccountSummary?> getAccountSummary() =>
      caller.callServerEndpoint<_i4.AccountSummary?>(
        'account',
        'getAccountSummary',
        {},
      );

  _i2.Future<_i5.Profile?> getProfile() =>
      caller.callServerEndpoint<_i5.Profile?>(
        'account',
        'getProfile',
        {},
      );

  _i2.Future<void> deleteAccount() => caller.callServerEndpoint<void>(
    'account',
    'deleteAccount',
    {},
  );
}

/// {@category Endpoint}
class EndpointAdmin extends EndpointAdminEndpointBase {
  EndpointAdmin(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'admin';

  _i2.Future<
    List<({_i6.AuthUserModel authUser, _i6.UserProfileModel userProfile})>
  >
  listAdminUsers() =>
      caller.callServerEndpoint<
        List<({_i6.AuthUserModel authUser, _i6.UserProfileModel userProfile})>
      >(
        'admin',
        'listAdminUsers',
        {},
      );

  _i2.Future<List<_i6.AuthUserModel>> listAuthUsers() =>
      caller.callServerEndpoint<List<_i6.AuthUserModel>>(
        'admin',
        'listAuthUsers',
        {},
      );

  _i2.Future<void> blockUser(_i1.UuidValue authUserId) =>
      caller.callServerEndpoint<void>(
        'admin',
        'blockUser',
        {'authUserId': authUserId},
      );

  _i2.Future<void> unblockUser(_i1.UuidValue authUserId) =>
      caller.callServerEndpoint<void>(
        'admin',
        'unblockUser',
        {'authUserId': authUserId},
      );

  _i2.Future<void> updateUserScope(
    _i1.UuidValue authUserId,
    List<String> scopeNames,
  ) => caller.callServerEndpoint<void>(
    'admin',
    'updateUserScope',
    {
      'authUserId': authUserId,
      'scopeNames': scopeNames,
    },
  );
}

/// {@category Endpoint}
class EndpointAuth extends _i1.EndpointRef {
  EndpointAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  _i2.Future<_i7.OtpVerificationResult> completeRegistration({
    required String email,
    required String name,
    required String gender,
    required String registrationToken,
    DateTime? birthday,
  }) => caller.callServerEndpoint<_i7.OtpVerificationResult>(
    'auth',
    'completeRegistration',
    {
      'email': email,
      'name': name,
      'gender': gender,
      'registrationToken': registrationToken,
      'birthday': birthday,
    },
  );
}

/// {@category Endpoint}
class EndpointEmailIdp extends _i8.EndpointEmailIdpBase {
  EndpointEmailIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<_i6.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i6.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i2.Future<_i1.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i2.Future<String> verifyRegistrationCode({
    required _i1.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i2.Future<_i6.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i6.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i2.Future<_i1.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i2.Future<String> verifyPasswordResetCode({
    required _i1.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// {@category Endpoint}
class EndpointFacebookIdp extends _i8.EndpointFacebookIdpBase {
  EndpointFacebookIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'facebookIdp';

  /// Validates a Facebook access token and either logs in the associated user or
  /// creates a new user account if the Facebook account ID is not yet known.
  ///
  /// If the access token is invalid or expired, the
  /// [FacebookAccessTokenVerificationException] will be thrown.
  @override
  _i2.Future<_i6.AuthSuccess> login({required String accessToken}) =>
      caller.callServerEndpoint<_i6.AuthSuccess>(
        'facebookIdp',
        'login',
        {'accessToken': accessToken},
      );

  @override
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'facebookIdp',
    'hasAccount',
    {},
  );
}

/// {@category Endpoint}
class EndpointGoogleIdp extends _i8.EndpointGoogleIdpBase {
  EndpointGoogleIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'googleIdp';

  /// Validates a Google ID token and either logs in the associated user or
  /// creates a new user account if the Google account ID is not yet known.
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _i2.Future<_i6.AuthSuccess> login({
    required String idToken,
    required String? accessToken,
  }) => caller.callServerEndpoint<_i6.AuthSuccess>(
    'googleIdp',
    'login',
    {
      'idToken': idToken,
      'accessToken': accessToken,
    },
  );

  /// Validates a Google authorization code from the web OAuth2 PKCE flow and
  /// either logs in the associated user or creates a new account.
  ///
  /// This is the web counterpart of [login], which accepts an ID token directly
  /// (used on native platforms via the `google_sign_in` package).
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _i2.Future<_i6.AuthSuccess> loginWithCode({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) => caller.callServerEndpoint<_i6.AuthSuccess>(
    'googleIdp',
    'loginWithCode',
    {
      'code': code,
      'codeVerifier': codeVerifier,
      'redirectUri': redirectUri,
    },
  );

  @override
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'googleIdp',
    'hasAccount',
    {},
  );
}

/// {@category Endpoint}
class EndpointJwtRefresh extends _i6.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i2.Future<_i6.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i6.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// {@category Endpoint}
class EndpointOtp extends _i1.EndpointRef {
  EndpointOtp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'otp';

  _i2.Future<void> sendOtp({required String email}) =>
      caller.callServerEndpoint<void>(
        'otp',
        'sendOtp',
        {'email': email},
      );

  _i2.Future<_i7.OtpVerificationResult> verifyOtp({
    required String email,
    required String code,
  }) => caller.callServerEndpoint<_i7.OtpVerificationResult>(
    'otp',
    'verifyOtp',
    {
      'email': email,
      'code': code,
    },
  );
}

/// {@category Endpoint}
class EndpointSecurity extends EndpointAdminEndpointBase {
  EndpointSecurity(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'security';

  _i2.Future<List<_i9.SecurityEvent>> listSecurityEvents({
    required int limit,
    required int offset,
    String? eventType,
    _i1.UuidValue? authUserId,
  }) => caller.callServerEndpoint<List<_i9.SecurityEvent>>(
    'security',
    'listSecurityEvents',
    {
      'limit': limit,
      'offset': offset,
      'eventType': eventType,
      'authUserId': authUserId,
    },
  );
}

class Modules {
  Modules(Client client) {
    auth_core = _i6.Caller(client);
    serverpod_auth_idp = _i8.Caller(client);
    auth = _i10.Caller(client);
  }

  late final _i6.Caller auth_core;

  late final _i8.Caller serverpod_auth_idp;

  late final _i10.Caller auth;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i11.Client? httpClientOverride,
  }) : super(
         host,
         _i12.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    account = EndpointAccount(this);
    admin = EndpointAdmin(this);
    auth = EndpointAuth(this);
    emailIdp = EndpointEmailIdp(this);
    facebookIdp = EndpointFacebookIdp(this);
    googleIdp = EndpointGoogleIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    otp = EndpointOtp(this);
    security = EndpointSecurity(this);
    modules = Modules(this);
  }

  late final EndpointAccount account;

  late final EndpointAdmin admin;

  late final EndpointAuth auth;

  late final EndpointEmailIdp emailIdp;

  late final EndpointFacebookIdp facebookIdp;

  late final EndpointGoogleIdp googleIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointOtp otp;

  late final EndpointSecurity security;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'account': account,
    'admin': admin,
    'auth': auth,
    'emailIdp': emailIdp,
    'facebookIdp': facebookIdp,
    'googleIdp': googleIdp,
    'jwtRefresh': jwtRefresh,
    'otp': otp,
    'security': security,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'auth_core': modules.auth_core,
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'auth': modules.auth,
  };
}
