---
name: security-review
description: Use this skill when adding authentication, handling user input, working with secrets, creating API endpoints, or implementing sensitive features.
---

# Security Review Skill

This skill ensures all code follows security best practices for Dart, Flutter, and Serverpod, identifying potential vulnerabilities.

## When to Activate

- Implementing authentication or authorization via Serverpod Auth
- Handling user input or file uploads
- Creating new Serverpod RPC endpoints
- Working with secrets or credentials (`passwords.yaml`)
- Implementing payment features
- Storing or transmitting sensitive data
- Integrating third-party APIs

## Security Checklist

### 1. Secrets Management

#### FAIL: NEVER Do This
```dart
const apiKey = "sk-proj-xxxxx";  // Hardcoded secret
const dbPassword = "password123"; // In source code
```

#### PASS: ALWAYS Do This (Serverpod)
Store secrets in `config/passwords.yaml`.

```dart
// Access passwords via Serverpod session
final apiKey = session.passwords['openAiApiKey'];

if (apiKey == null) {
  throw Exception('openAiApiKey not configured');
}
```

#### Verification Steps
- [ ] No hardcoded API keys, tokens, or passwords
- [ ] Server secrets securely managed in `passwords.yaml`
- [ ] Client secrets managed via `flutter_dotenv` or injected via CI/CD
- [ ] No secrets committed in git history

### 2. Input Validation

#### Always Validate User Input
```dart
class MarketEndpoint extends Endpoint {
  Future<void> createMarket(Session session, Market market) async {
    // 1. Validate domain rules
    if (market.name.isEmpty || market.name.length > 100) {
      throw ApiException(message: 'Invalid market name');
    }
    
    // 2. Proceed with DB insert
    await Market.insert(session, market);
  }
}
```

#### Verification Steps
- [ ] Domain entities validate their own state via `.validate()` methods
- [ ] Endpoints validate parameters before executing DB operations
- [ ] Whitelist validation (not blacklist)
- [ ] Error messages don't leak sensitive info

### 3. SQL Injection Prevention

#### PASS: ALWAYS Use Serverpod ORM
```dart
// Safe - ORM automatically parameterizes queries
final markets = await Market.find(
  session,
  where: (t) => t.name.equals(userInput),
);
```

#### Verification Steps
- [ ] All database queries use Serverpod ORM
- [ ] No string concatenation in raw SQL (`session.db.query`)

### 4. Authentication & Authorization

#### Authorization Checks in Endpoints
```dart
class AdminEndpoint extends Endpoint {
  // ALWAYS verify authorization scope first
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {Scope('admin')};

  Future<void> deleteData(Session session) async {
    // Safe: Only users logged in and holding 'admin' scope can reach here
  }
}
```

#### Row Level Security
While Serverpod doesn't use Postgres RLS by default, always explicitly check ownership in code:

```dart
Future<void> updatePost(Session session, Post post) async {
  final authInfo = await session.authenticated;
  if (post.authorId != authInfo?.userId) {
    throw ApiException(message: 'Unauthorized');
  }
  await Post.update(session, post);
}
```

#### Verification Steps
- [ ] Endpoints require login via `requireLogin` where appropriate
- [ ] Scopes are enforced for elevated privileges
- [ ] Row ownership explicitly verified before mutations

### 5. Sensitive Data Exposure

#### Logging
```dart
// FAIL: WRONG: Logging sensitive data
session.log('User login: ${password}');

// PASS: CORRECT: Redact sensitive data
session.log('User login: ${userId}');
```

#### Error Messages
```dart
// FAIL: WRONG: Exposing internal details to the client
catch (error) {
  throw ApiException(message: error.toString()); // Might expose SQL errors
}

// PASS: CORRECT: Generic error messages
catch (error, stackTrace) {
  session.log('Internal error', exception: error, trace: stackTrace);
  throw ApiException(message: 'An error occurred. Please try again.');
}
```

#### Verification Steps
- [ ] No passwords, tokens, or secrets in logs
- [ ] Client error messages are generic
- [ ] Detailed errors and stack traces only in server logs

### 6. Dependency Security

#### Regular Updates
```bash
# Check for outdated packages in Dart/Flutter
dart pub outdated
flutter pub outdated

# Update dependencies
dart pub upgrade
```

#### Verification Steps
- [ ] Dependencies up to date
- [ ] `pubspec.lock` committed
- [ ] Regular security updates applied

## Pre-Deployment Security Checklist

Before ANY production deployment:

- [ ] **Secrets**: No hardcoded secrets, `passwords.yaml` securely provisioned
- [ ] **Input Validation**: All user inputs and endpoint arguments validated
- [ ] **SQL Injection**: All queries use ORM or parameterized bindings
- [ ] **Authentication**: `requireLogin` enabled where necessary
- [ ] **Authorization**: Scope/Role checks in place
- [ ] **HTTPS**: Enforced in production server configuration
- [ ] **Error Handling**: No sensitive data leaked in `ApiException`
- [ ] **Logging**: No sensitive data logged
- [ ] **Dependencies**: Up to date

**Remember**: Security is not optional. One vulnerability can compromise the entire platform. When in doubt, err on the side of caution.
