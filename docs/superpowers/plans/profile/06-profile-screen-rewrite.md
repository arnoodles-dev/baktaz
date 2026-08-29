# Task 6: ProfileScreen Rewrite (Edit Flow, Avatar Upload, Social Links)

**Files:**
- Create: `baktaz_flutter/lib/features/account/data/service/avatar_upload_service.dart`
- Modify: `baktaz_flutter/lib/features/account/domain/interface/i_account_repository.dart` (add getAvatarUploadUrl)
- Modify: `baktaz_flutter/lib/features/account/data/repository/account_repository.dart` (add getAvatarUploadUrl)
- Modify: `baktaz_flutter/lib/features/account/domain/cubit/profile/profile_cubit.dart`
- Read: `baktaz_flutter/lib/features/account/domain/cubit/profile/profile_state.dart`
- Modify: `baktaz_flutter/lib/features/account/presentation/views/screens/my_account/profile_screen.dart`

**Interfaces:**
- Consumes: `Profile`, `ProfileCubit`, `IAccountRepository`, `IAvatarUploadService`, `image_picker`
- Produces: Complete edit flow in `ProfileScreen`, `ProfileCubit.updateProfile()`, avatar image picker upload via `IAvatarUploadService`, social provider read-only list.

---

- [ ] **Step 1: Create IAvatarUploadService**

Create `baktaz_flutter/lib/features/account/data/service/avatar_upload_service.dart`:
```dart
import 'dart:typed_data';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class IAvatarUploadService {
  TaskResult<String> uploadAvatar({
    required String uploadUrl,
    required Uint8List bytes,
    String contentType = 'image/webp',
  });
}

@LazySingleton(as: IAvatarUploadService)
final class AvatarUploadService implements IAvatarUploadService {
  const AvatarUploadService();

  @override
  TaskResult<String> uploadAvatar({
    required String uploadUrl,
    required Uint8List bytes,
    String contentType = 'image/webp',
  }) => TaskResult<String>.tryCatch(
    () async {
      final http.Response response = await http.put(
        Uri.parse(uploadUrl),
        body: bytes,
        headers: {'Content-Type': contentType},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw HttpException('Upload failed: ${response.statusCode} ${response.reasonPhrase}');
      }

      // Return success (permanent URL will be set by caller from AvatarUploadUrl.permanentUrl)
      return 'success';
    },
    (Object error, StackTrace stackTrace) {
      return Failure.server(HttpStatusCode.serverpod, error.toString());
    },
  );
}
```

---

- [ ] **Step 2: Update IAccountRepository & AccountRepository for getAvatarUploadUrl**

Modify `baktaz_flutter/lib/features/account/domain/interface/i_account_repository.dart`:
```dart
// ... existing methods ...
  TaskResult<serverpod.AvatarUploadUrl> getAvatarUploadUrl();
```

Modify `baktaz_flutter/lib/features/account/data/repository/account_repository.dart`:
```dart
@override
TaskResult<serverpod.AvatarUploadUrl> getAvatarUploadUrl() => TaskResult<serverpod.AvatarUploadUrl>.tryCatch(
  () async {
    final serverpod.AvatarUploadUrl? result = await _retry.retry(
      () => _serverpod.client.account.getAvatarUploadUrl(),
      retryIf: (Exception exception) => exception is SocketException || exception is TimeoutException,
    );

    if (result == null) throw const FormatException('Avatar upload URL is null');
    return result;
  },
  (Object error, StackTrace stackTrace) {
    _talker.handle(error, stackTrace);
    return Failure.server(StatusCode.serverpod, error.toString());
  },
);
```

---

- [ ] **Step 3: Update ProfileCubit & ProfileState**

Modify `baktaz_flutter/lib/features/account/domain/cubit/profile/profile_cubit.dart`:
```dart
Future<void> updateProfile({
  required String firstName,
  required String lastName,
  String? mobileNumber,
  DateTime? birthday,
  String? gender,
  String? avatarUrl,
}) async {
  await safeRun(
    onLoading: (bool isLoading) {
      safeEmit(stateValue.copyWith(queryStatus: isLoading ? const QueryStatus.loading() : const QueryStatus.done()));
    },
    action: () async {
      final Result<Profile> result = await _accountRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        mobileNumber: mobileNumber,
        birthday: birthday,
        gender: gender,
        avatarUrl: avatarUrl,
      ).run();

      result.fold(
        _failureHandler.handleFailure,
        (Profile profile) => safeEmit(stateValue.copyWith(profile: profile, queryStatus: const QueryStatus.done())),
      );
    },
  );
}

Future<void> getAvatarUploadUrl() async {
  final Result<serverpod.AvatarUploadUrl> result = await _accountRepository.getAvatarUploadUrl().run();
  result.fold(
    _failureHandler.handleFailure,
    (serverpod.AvatarUploadUrl uploadUrl) => safeEmit(stateValue.copyWith(avatarUploadUrl: uploadUrl)),
  );
}

Future<void> loadLinkedProviders() async {
  final Result<List<String>> result = await _accountRepository.getLinkedProviders().run();
  result.fold(
    _failureHandler.handleFailure,
    (providers) => safeEmit(stateValue.copyWith(linkedProviders: providers)),
  );
}
```

Ensure `profile_state.dart` includes:
```dart
@freezed
sealed class ProfileState with _$ProfileState {
  const factory ProfileState({
    required QueryStatus queryStatus,
    Profile? profile,
    serverpod.AvatarUploadUrl? avatarUploadUrl,
    List<String> linkedProviders,
  }) = _ProfileState;

  factory ProfileState.initial() => const _ProfileState(
    queryStatus: QueryStatus.loading(),
    linkedProviders: [],
  );
}
```

---

- [ ] **Step 4: Rewrite ProfileScreen presentation**

In `baktaz_flutter/lib/features/account/presentation/views/screens/my_account/profile_screen.dart`:

Key UI structure:
```
AppBar: (←) Profile     (Save)
----------------------------------
[Avatar 120px] (camera icon overlay)
  Tap → bottom sheet: Take Photo / Choose from Gallery / Remove Photo (red, separate)

FIRST NAME    [ Juan          ] [edit icon]
LAST NAME     [ Dela Cruz     ] [edit icon]
USERNAME      [ @juandelacruz  ] [edit icon]
EMAIL         [ juan@example.com ] (read-only, gray)
MOBILE        [ +63 912 345 6789 ] [edit icon]

───────────────────────────────
Linked Accounts
───────────────────────────────
Google    [✓] Linked
Facebook  [ ] Not Linked
```

- Avatar: tap → bottom sheet with "Take Photo", "Choose from Gallery", and **separate red "Remove Photo"**
- Edit fields: inline per-field with pencil icon; Save button in AppBar commits all
- Linked Accounts: read-only list with green check for linked, gray for not linked

---

- [ ] **Step 5: Add avatar upload handler (uses IAvatarUploadService)**

In ProfileScreen:
```dart
void _handleAvatarChange() async {
  final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (image == null) return;

  // 1. Get presigned URL
  await _cubit.getAvatarUploadUrl();
  final serverpod.AvatarUploadUrl? uploadUrl = _cubit.state.avatarUploadUrl;
  if (uploadUrl == null) return;

  // 2. Upload file via AvatarUploadService
  final Uint8List bytes = await image.readAsBytes();
  final Result<String> uploadResult = await _avatarUploadService.uploadAvatar(
    uploadUrl: uploadUrl.uploadUrl,
    bytes: await image.readAsBytes(),
  ).run();

  uploadResult.fold(
    _failureHandler.handleFailure,
    (_) async {
      // On success, update profile with permanent URL from server
      await _cubit.updateProfile(avatarUrl: uploadUrl.permanentUrl);
    },
  );
}

void _removeAvatar() async {
  await _cubit.updateProfile(avatarUrl: '');
}
```

---

- [ ] **Step 6: Add social providers display**

Display linked providers as read-only tiles (green check if linked, gray if not):
```dart
class _SocialProvidersSection extends StatelessWidget {
  final List<String> linkedProviders;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BaktazSectionHeader(title: context.i18n.account.social_providers),
      BaktazCard(
        child: Column(
          children: [
            _ProviderTile(
              name: 'Google',
              icon: Icons.g_translate,
              isLinked: linkedProviders.contains('google'),
            ),
            BaktazDivider(),
            _ProviderTile(
              name: 'Facebook',
              icon: Icons.facebook,
              isLinked: linkedProviders.contains('facebook'),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ProviderTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isLinked;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(name),
    trailing: isLinked
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.i18n.account.linked),
              Gap.xSmall(),
              Icon(Icons.check_circle, color: Colors.green),
            ],
          )
        : Text(
            context.i18n.account.not_linked,
            style: TextStyle(color: Colors.grey),
          ),
  );
}
```

---

- [ ] **Step 7: Register AvatarUploadService in injection**

Ensure `AvatarUploadService` is registered in `baktaz_flutter/lib/app/injection/service_locator.dart` (auto-registered via `@LazySingleton`).

---

- [ ] **Step 6: Run build_runner on baktaz_flutter**

Run:
```bash
cd /Users/Arnold/Projects/baktaz/baktaz_flutter
fvm flutter pub run build_runner build --delete-conflicting-outputs
```
Expected: Freezed code regenerated without conflicts.

---

- [ ] **Step 7: Commit ProfileScreen rewrite**

```bash
cd /Users/Arnold/Projects/baktaz
git add baktaz_flutter/lib/features/account/
git commit -m "feat(flutter): rewrite ProfileScreen with edit flow, presigned avatar upload via AvatarUploadService, and social links"
```
