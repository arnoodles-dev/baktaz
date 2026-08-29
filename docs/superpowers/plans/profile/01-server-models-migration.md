# Task 1: Server Models Update & Migration

**Files:**
- Modify: `baktaz_server/lib/src/features/account/domain/model/user_info.spy.yaml`
- Modify: `baktaz_server/lib/src/features/account/domain/model/account_summary.spy.yaml`
- Modify: `baktaz_server/lib/src/features/account/domain/model/profile.spy.yaml`
- Modify: `baktaz_server/lib/src/features/auth/domain/models/registration_form.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/domain/model/account_challenge_stats.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/domain/model/avatar_upload_url.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/domain/model/update_profile_request.spy.yaml`

**Interfaces:**
- Consumes: Existing Serverpod schema setup
- Produces: `UserInfo`, `AccountSummary`, `Profile`, `RegistrationForm`, `AccountChallengeStats`, `AvatarUploadUrl`, `UpdateProfileRequest` server models and generated client code.

---

- [ ] **Step 1: Update `.spy.yaml` model files on server**

Update `baktaz_server/lib/src/features/account/domain/model/user_info.spy.yaml`:
```yaml
class: UserInfo
table: user_info
fields:
  id: UuidValue?, defaultPersist=random
  firstName: String
  lastName: String
  username: String
  gender: Gender, default=unknown
  birthday: DateTime?
  updatedAt: DateTime?
  mobileNumber: String?
  avatarUrl: String?
indexes:
  username_unique_idx:
    fields: username
    unique: true
```

Update `baktaz_server/lib/src/features/account/domain/model/account_summary.spy.yaml` (matches Account spec v1.1 nested structure):
```yaml
class: AccountSummary
fields:
  userInfo: UserInfo
  isPremiumHost: bool
  stats: AccountChallengeStats
```

Update `baktaz_server/lib/src/features/account/domain/model/profile.spy.yaml`:
```yaml
class: Profile
fields:
  firstName: String
  lastName: String
  username: String
  gender: Gender
  email: String?
  mobileNumber: String?
  birthday: DateTime?
  age: int?
  imageUrl: Uri?
  updatedAt: DateTime?
```

Update `baktaz_server/lib/src/features/auth/domain/models/registration_form.spy.yaml`:
```yaml
class: RegistrationForm
fields:
  email: String
  firstName: String
  lastName: String
  gender: String
  registrationToken: String
  birthday: DateTime?
```

Create `baktaz_server/lib/src/features/account/domain/model/account_challenge_stats.spy.yaml`:
```yaml
class: AccountChallengeStats
fields:
  totalChallengeSteps: int
  challengesJoined: int
  challengesWon: int
  winRatePercentage: double
```

Create `baktaz_server/lib/src/features/account/domain/model/avatar_upload_url.spy.yaml`:
```yaml
class: AvatarUploadUrl
fields:
  uploadUrl: String
  fileKey: String
  permanentUrl: String
  expiresAt: DateTime
```

Create `baktaz_server/lib/src/features/account/domain/model/update_profile_request.spy.yaml`:
```yaml
class: UpdateProfileRequest
fields:
  firstName: String
  lastName: String
  mobileNumber: String?
  birthday: DateTime?
  gender: String?
  avatarUrl: String?
```

---

- [ ] **Step 2: Run Serverpod migration and codegen**

Run:
```bash
cd /Users/Arnold/Projects/baktaz
melos run build_runner
cd baktaz_server && serverpod generate
```

Then create migration:
```bash
cd /Users/Arnold/Projects/baktaz/baktaz_server
fvm serverpod create-migration --tag profile-header-update
```
Expected: New migration folder generated under `migrations/`.

---

- [ ] **Step 3: Verify migration SQL includes backfill logic**

Check the generated migration file in `baktaz_server/migrations/` — it should:
- Add columns: `first_name`, `last_name`, `username`, `avatar_url` to `user_info`
- Create unique index `user_info_username_unique_idx` on `username`
- Backfill `username` from `UserProfile.email` (local-part, lowercase)
- Resolve collisions with random 4-digit suffix

If backfill is missing, manually edit the migration to add:
```sql
-- Backfill username from email for existing users
UPDATE user_info ui
SET username = sub.username
FROM (
  SELECT ui2.id,
         LOWER(SPLIT_PART(up.email, '@', 1)) as username
  FROM user_info ui2
  JOIN account a ON a.user_info_id = ui2.id
  JOIN serverpod_auth_core_profile up ON up.auth_user_id = a.auth_user_id
  WHERE ui2.username = ''
) sub
WHERE user_info.id = sub.id;

-- Resolve collisions: append random suffix to duplicates
WITH ranked AS (
  SELECT id, username,
         ROW_NUMBER() OVER (PARTITION BY username ORDER BY id) as rn
  FROM user_info
  WHERE username != ''
)
UPDATE user_info
SET username = username || substr((random() * 9000 + 1000)::integer::text, 1, 4)
FROM ranked
WHERE user_info.id = ranked.id AND ranked.rn > 1;
```

---

- [ ] **Step 4: Run migrations and verify**

Run:
```bash
cd /Users/Arnold/Projects/baktaz/baktaz_server
rtk make apply_migrations
```

Verify:
```bash
psql -d baktaz -c "SELECT username FROM user_info WHERE username = ''"
```
Expected: 0 rows

---

- [ ] **Step 5: Commit schema changes and generated files**

```bash
cd /Users/Arnold/Projects/baktaz
git add baktaz_server/ baktaz_client/
git commit -m "feat(server): update UserInfo, Profile, AccountSummary, and RegistrationForm models with migrations"
```
