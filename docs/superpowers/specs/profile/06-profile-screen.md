# Profile Header & Lifetime Stats — ProfileScreen Rewrite

> **Document Version:** 1.0  
> **Date:** 2026-08-29  
> **Parent Spec:** `docs/superpowers/specs/account/profile/00-overview.md`

---

## 1. ProfileScreen Layout

**File:** `baktaz_flutter/lib/features/account/presentation/views/screens/my_account/profile_screen.dart`

### Layout Structure

```
AppBar: (←) Profile     (Save)
----------------------------------
[Avatar 120px] (camera icon overlay)
  Tap → bottom sheet: Take Photo / Choose from Gallery / Remove Photo

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

### Widget Hierarchy

```dart
Scaffold(
  appBar: BaktazAppBar(title: 'Profile', actions: [SaveButton]),
  body: SingleChildScrollView(
    child: Column(
      children: [
        // Avatar Section
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(padding: EdgeInsets.only(top: 60), child: FieldsSection()),
            Positioned(top: -60, child: AvatarWithOverlay()),
          ],
        ),
        // Linked Accounts Section
        LinkedAccountsSection(),
        // Account Settings (Delete, Logout)
        AccountSettingsSection(),
      ],
    ),
  ),
)
```

---

## 2. Avatar Upload Flow

### User Flow
1. Tap avatar → bottom sheet: "Take Photo", "Choose from Gallery", "Remove Photo"
2. Select image → fetch presigned upload URL → upload to S3 → update profile with new URL

### Implementation

```dart
void _handleAvatarTap() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.camera_alt),
          title: Text(context.i18n.account.take_photo),
          onTap: () => _pickAndUploadImage(ImageSource.camera),
        ),
        ListTile(
          leading: Icon(Icons.photo_library),
          title: Text(context.i18n.account.choose_from_gallery),
          onTap: () => _pickAndUploadImage(ImageSource.gallery),
        ),
        if (profile.imageUrl != null)
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text(context.i18n.account.remove_photo, style: TextStyle(color: Colors.red)),
            onTap: () => _removeAvatar(),
          ),
      ],
    ),
  );
}

Future<void> _pickAndUploadImage(ImageSource source) async {
  final XFile? image = await ImagePicker().pickImage(source: source);
  if (image == null) return;

  // 1. Get presigned URL
  final Result<serverpod.AvatarUploadUrl> result = await _cubit.getAvatarUploadUrl().run();
  final serverpod.AvatarUploadUrl? uploadUrl = result.toOption().toNullable();
  if (uploadUrl == null) return;

  // 2. Upload file to presigned URL
  final Uint8List bytes = await image.readAsBytes();
  final http.Response response = await http.put(
    Uri.parse(uploadUrl.uploadUrl),
    body: bytes,
    headers: {'Content-Type': 'image/webp'},
  );

  // 3. Update profile with permanent URL
  if (response.statusCode == 200 || response.statusCode == 201) {
    final String permanentUrl = 'https://${...bucket...}/${uploadUrl.fileKey}';
    await _cubit.updateProfile(avatarUrl: permanentUrl);
  }
}

Future<void> _removeAvatar() async {
  await _cubit.updateProfile(avatarUrl: '');
}
```

> **Note:** For local development, presigned URL will be `http://10.0.2.2:8080/...`. Permanent URL construction depends on S3 bucket configuration.

---

## 3. Edit Flow (First Name, Last Name, Username, Mobile)

### Inline Edit Pattern

Each editable field shows:
- Current value
- Edit icon (pencil)
- Tap → opens inline edit dialog or switches to edit mode
- Save → calls `ProfileCubit.updateProfile()`

### Implementation Pattern

```dart
class _EditableField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaktazText(text: label, style: context.textTheme.bodySmall),
            BaktazText(text: value, style: context.textTheme.titleMedium),
          ],
        ),
      ),
      IconButton(icon: Icon(Icons.edit), onPressed: onEdit),
    ],
  );
}
```

### Save Action
```dart
Future<void> _saveProfile() async {
  await _cubit.updateProfile(
    firstName: firstNameController.text,
    lastName: lastNameController.text,
    username: usernameController.text,
    mobileNumber: mobileNumberController.text,
    avatarUrl: currentAvatarUrl,
  );
}
```

---

## 4. Social Provider Display

### Read-Only Status List

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

## 5. ProfileCubit Updates

**File:** `baktaz_flutter/lib/features/account/domain/cubit/profile/profile_cubit.dart`

### Add `updateProfile` Method

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
```

### Add `getAvatarUploadUrl` and `getLinkedProviders` Methods

```dart
Future<void> getAvatarUploadUrl() async {
  final Result<serverpod.AvatarUploadUrl> result = await _accountRepository.getAvatarUploadUrl().run();
  result.fold(_failureHandler.handleFailure, (url) => safeEmit(stateValue.copyWith(avatarUploadUrl: url)));
}

Future<void> loadLinkedProviders() async {
  final Result<List<String>> result = await _accountRepository.getLinkedProviders().run();
  result.fold(_failureHandler.handleFailure, (providers) => safeEmit(stateValue.copyWith(linkedProviders: providers)));
}
```

---

## 6. ProfileState Updates

**File:** `baktaz_flutter/lib/features/account/domain/cubit/profile/profile_state.dart`

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

## 7. Remove Photo Behavior

When user taps "Remove Photo":
1. Call `_cubit.updateProfile(avatarUrl: '')`
2. Server sets `avatarUrl = null` in `UserInfo`
3. S3 object marked for async cleanup (background job)
4. UI immediately shows default avatar placeholder
