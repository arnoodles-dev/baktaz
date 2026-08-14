---
name: coding-standards
description: Baseline cross-project coding conventions for naming, readability, immutability, and code-quality review. Use detailed frontend or backend skills for framework-specific patterns.
---

# Coding Standards & Best Practices

Baseline coding conventions applicable across projects.

This skill is the shared floor, not the detailed framework playbook.

- Use `rule-flutter-architecture` for Flutter state, forms, rendering, and UI architecture.
- Use `rule-serverpod-architecture` for repository/service layers, endpoint design, validation, and server-specific concerns.
- Use `rules/common/coding-style.md` when you need the shortest reusable rule layer instead of a full skill walkthrough.

## When to Activate

- Starting a new project or module
- Reviewing code for quality and maintainability
- Refactoring existing code to follow conventions
- Enforcing naming, formatting, or structural consistency
- Setting up linting, formatting, or type-checking rules
- Onboarding new contributors to coding conventions

## Scope Boundaries

Activate this skill for:
- descriptive naming
- immutability defaults
- readability, KISS, DRY, and YAGNI enforcement
- error-handling expectations and code-smell review

Do not use this skill as the primary source for:
- Flutter composition, state management, or rendering patterns
- backend architecture, API design, or database layering
- domain-specific framework guidance when a narrower ECC skill already exists

## Code Quality Principles

### 1. Readability First
- Code is read more than written
- Clear variable and function names
- Self-documenting code preferred over comments
- Consistent formatting

### 2. KISS (Keep It Simple, Stupid)
- Simplest solution that works
- Avoid over-engineering
- No premature optimization
- Easy to understand > clever code

### 3. DRY (Don't Repeat Yourself)
- Extract common logic into functions
- Create reusable components
- Share utilities across modules
- Avoid copy-paste programming

### 4. YAGNI (You Aren't Gonna Need It)
- Don't build features before they're needed
- Avoid speculative generality
- Add complexity only when required
- Start simple, refactor when needed

## Dart Standards

### Variable Naming

```dart
// PASS: GOOD: Descriptive names
const marketSearchQuery = 'election';
const isUserAuthenticated = true;
const totalRevenue = 1000;

// FAIL: BAD: Unclear names
const q = 'election';
const flag = true;
const x = 1000;
```

### Function Naming

```dart
// PASS: GOOD: Verb-noun pattern
Future<void> fetchMarketData(String marketId) async { }
double calculateSimilarity(List<double> a, List<double> b) { return 0.0; }
bool isValidEmail(String email) { return true; }

// FAIL: BAD: Unclear or noun-only
Future<void> market(String id) async { }
double similarity(List<double> a, List<double> b) { return 0.0; }
bool email(String e) { return true; }
```

### Immutability Pattern (CRITICAL)

```dart
// PASS: ALWAYS use copyWith for objects and spread for collections
final updatedUser = user.copyWith(name: 'New Name');
final updatedArray = [...items, newItem];

// FAIL: NEVER mutate directly
user.name = 'New Name';  // BAD
items.add(newItem);      // BAD
```

### Error Handling

```dart
// PASS: GOOD: Comprehensive error handling
Future<Map<String, dynamic>> fetchData(String url) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }

    return jsonDecode(response.body);
  } catch (error, stackTrace) {
    log('Fetch failed', error: error, stackTrace: stackTrace);
    throw Exception('Failed to fetch data');
  }
}

// FAIL: BAD: No error handling
Future<Map<String, dynamic>> fetchData(String url) async {
  final response = await http.get(Uri.parse(url));
  return jsonDecode(response.body);
}
```

### Async/Await Best Practices

```dart
// PASS: GOOD: Parallel execution when possible
final results = await Future.wait([
  fetchUsers(),
  fetchMarkets(),
  fetchStats(),
]);
final users = results[0];
final markets = results[1];

// FAIL: BAD: Sequential when unnecessary
final users = await fetchUsers();
final markets = await fetchMarkets();
final stats = await fetchStats();
```

### Type Safety

```dart
// PASS: GOOD: Proper types
class Market {
  final String id;
  final String name;
  final MarketStatus status;
  final DateTime createdAt;
  
  const Market({required this.id, required this.name, required this.status, required this.createdAt});
}

Future<Market> getMarket(String id) async {
  // Implementation
}

// FAIL: BAD: Using 'dynamic'
Future<dynamic> getMarket(dynamic id) async {
  // Implementation
}
```

## Flutter Best Practices

### Widget Structure

```dart
// PASS: GOOD: Strongly typed StatelessWidget
class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool disabled;
  final ButtonVariant variant;

  const AppButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.disabled = false,
    this.variant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      child: child,
    );
  }
}

// FAIL: BAD: Helper methods that return widgets instead of proper classes
Widget buildButton(Widget child, VoidCallback onPressed) {
  return ElevatedButton(onPressed: onPressed, child: child);
}
```

### State Management (Cubit/Bloc)

```dart
// PASS: GOOD: Proper state updates via copyWith
class MyCubit extends Cubit<MyState> {
  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }
}

// FAIL: BAD: Mutating state directly
class MyCubit extends Cubit<MyState> {
  void increment() {
    state.count++;
    emit(state); // BAD
  }
}
```

### Conditional Rendering

```dart
// PASS: GOOD: Clear conditional rendering using if statements in lists
Column(
  children: [
    if (isLoading) const CircularProgressIndicator(),
    if (error != null) ErrorMessage(error: error),
    if (data != null) DataDisplay(data: data),
  ],
)

// FAIL: BAD: Ternary hell
isLoading 
  ? const CircularProgressIndicator() 
  : error != null 
    ? ErrorMessage(error: error) 
    : data != null 
      ? DataDisplay(data: data) 
      : const SizedBox.shrink()
```

## Serverpod API Best Practices

### Endpoint Definition

```dart
// PASS: GOOD: Clear, typed endpoints
class MarketEndpoint extends Endpoint {
  Future<Market?> getMarket(Session session, String id) async {
    return await Market.findById(session, int.parse(id));
  }
  
  Future<void> createMarket(Session session, Market market) async {
    market.validate();
    await Market.insert(session, market);
  }
}
```

### Response Format

```dart
// Serverpod generates serialization for models defined in .spy.yaml automatically.
// Ensure your models include all necessary fields instead of returning raw JSON.
class ApiResponse {
  final bool success;
  final String? error;
}
```

## File Organization

### Project Structure

```
<project>/
├── <project>_flutter/           # Flutter Mobile/Web App
│   ├── lib/
│   │   ├── core/           # Core configurations and DI
│   │   ├── features/       # Feature-driven architecture (auth, dashboard)
│   │   └── shared/         # Shared widgets and utilities
├── <project>_server/            # Serverpod Backend
│   ├── lib/
│   │   ├── src/
│   │   │   ├── endpoints/  # API endpoints
│   │   │   └── generated/  # Serverpod generated models
│   └── protocol/           # .spy.yaml definitions
└── <project>_client/            # Auto-generated client package
```

### File Naming

```
lib/features/auth/presentation/screens/login_screen.dart   # snake_case for files
lib/core/utils/date_formatter.dart                         # snake_case for utilities
```

## Comments & Documentation

### When to Comment

```dart
// PASS: GOOD: Explain WHY, not WHAT
// Use exponential backoff to avoid overwhelming the API during outages
final delay = math.min(1000 * math.pow(2, retryCount), 30000);

// FAIL: BAD: Stating the obvious
// Increment counter by 1
count++;
```

### DartDoc for Public APIs

```dart
/// Searches markets using semantic similarity.
///
/// [query] is the natural language search query.
/// [limit] defines the maximum number of results (default: 10).
/// Returns a list of [Market]s sorted by similarity score.
/// Throws an [Exception] if the search service is unavailable.
Future<List<Market>> searchMarkets(String query, {int limit = 10}) async {
  // Implementation
}
```

## Performance Best Practices

### Const Constructors

```dart
// PASS: GOOD: Use const whenever possible to prevent unnecessary rebuilds
const Padding(
  padding: EdgeInsets.all(8.0),
  child: Text('Static Text'),
);

// FAIL: BAD: Missing const
Padding(
  padding: EdgeInsets.all(8.0),
  child: Text('Static Text'), // BAD: Will rebuild unnecessarily
);
```

### Lazy Loading

```dart
// PASS: GOOD: Use ListView.builder for long/infinite lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
);

// FAIL: BAD: Using Column or standard ListView for thousands of items
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
);
```

## Testing Standards

### Test Structure (AAA Pattern)

```dart
test('calculates similarity correctly', () {
  // Arrange
  final vector1 = [1.0, 0.0, 0.0];
  final vector2 = [0.0, 1.0, 0.0];

  // Act
  final similarity = calculateCosineSimilarity(vector1, vector2);

  // Assert
  expect(similarity, equals(0.0));
});
```

### Test Naming

```dart
// PASS: GOOD: Descriptive test names
test('returns empty array when no markets match query', () {});
test('throws exception when API key is missing', () {});

// FAIL: BAD: Vague test names
test('works', () {});
test('test search', () {});
```

## Code Smell Detection

Watch for these anti-patterns:

### 1. Long Functions
```dart
// FAIL: BAD: Function > 50 lines
void processMarketData() {
  // 100 lines of code
}

// PASS: GOOD: Split into smaller functions
void processMarketData() {
  final validated = validateData();
  final transformed = transformData(validated);
  saveData(transformed);
}
```

### 2. Deep Nesting
```dart
// FAIL: BAD: 5+ levels of nesting
if (user != null) {
  if (user.isAdmin) {
    if (market != null) {
      if (market.isActive) {
        if (hasPermission) {
          // Do something
        }
      }
    }
  }
}

// PASS: GOOD: Early returns
if (user == null) return;
if (!user.isAdmin) return;
if (market == null) return;
if (!market.isActive) return;
if (!hasPermission) return;

// Do something
```

### 3. Magic Numbers
```dart
// FAIL: BAD: Unexplained numbers
if (retryCount > 3) { }
Future.delayed(const Duration(milliseconds: 500));

// PASS: GOOD: Named constants
const maxRetries = 3;
const debounceDelay = Duration(milliseconds: 500);

if (retryCount > maxRetries) { }
Future.delayed(debounceDelay);
```

### 4. Hardcoded User-Facing Strings
```dart
// FAIL: BAD: Hardcoded strings in UI
return const AppButton(child: Text('Submit'));

// PASS: GOOD: Using localization keys
return AppButton(child: Text(context.l10n.actionsSubmit));
```

### 5. Over-Encapsulation (Single-Value Wrappers)
```dart
// FAIL: BAD: Wrapping single primitives needlessly (Applies to Domain Models and DTOs)
class UserEmail { 
  final String value;
  UserEmail(this.value); 
}

// PASS: GOOD: Using primitives directly, or proper Value Objects strictly where domain validation is needed
typedef UserEmail = String; // Or just use String directly for DTOs
```

### 6. Ignoring Language Features (Extensions & Enums)
```dart
// FAIL: BAD: Standalone utilities or primitive categorizations
DateTime getNextDay(DateTime date) { /* ... */ }
const statusActive = 'active';

// PASS: GOOD: Use Extensions and Enhanced Enums
// e.g. date.nextDay
enum Status { active, inactive }
extension DateTimeX on DateTime {
  DateTime get nextDay => this.add(const Duration(days: 1));
}
```

**Remember**: Code quality is not negotiable. Clear, maintainable code enables rapid development and confident refactoring.
