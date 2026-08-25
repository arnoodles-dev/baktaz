# Flutter Feature Workflow — Step by Step

This file contains the extracted step-by-step feature workflow from `flutter-architecture.md`.

---

## Overview

This guide walks through creating a new feature in the Flutter monorepo, from presentation layer through to codegen.

**Assumptions:**
- Feature follows clean architecture: Data → Domain → Presentation
- Uses `CubitSignal` for state management
- Uses `BlocSignalPresentationMixin` for one-shot presentation events
- Follows error-handling-architecture.md Pattern B
- Uses Serverpod for backend communication

---

## Step 1: Create Directory Structure

Create the feature directories:

```
lib/features/<feature_name>/
├── data/
│   ├── dto/
│   ├── repository/
│   └── service/
├── domain/
│   ├── cubit/
│   ├── entity/
│   └── interface/
└── presentation/
    ├── views/
    ├── widgets/
    │   └── dialogs/
    └── ...
```

---

## Step 2: Presentation Layer

### 2a. Create Screens/Widgets

Create `presentation/views/<feature_name>_screen.dart`:

```dart
class <FeatureName>Screen extends HookWidget {
  const <FeatureName>Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<<FeatureName>Cubit>();
    final state = useSignalValue(cubit.state);

    return BlocSignalBuilder<<FeatureName>Cubit, <FeatureName>State>(
      bloc: cubit,
      builder: (context, state) {
        return switch (state) {
          <FeatureName>StateInitial() => ...,
          <FeatureName>StateLoading() => const LoadingIndicator(),
          <FeatureName>StateLoaded(:final data) => ...,
          <FeatureName>StateError() => const ErrorWidget(),
        };
      },
    );
  }
}
```

### 2b. Create Dialogs (if needed)

Create `presentation/widgets/dialogs/<feature_name>_dialog.dart`:

```dart
class <FeatureName>Dialog extends StatelessWidget {
  const <FeatureName>Dialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const <FeatureName>Dialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: context.l10n.featureNameTitle,
      // ...
    );
  }
}
```

---

## Step 3: Add Routing

### 3a. Define Route

In `app/router/`:

```dart
@TypedGoRoute(
  path: '/<feature>',
  builder: (context, state) => const <FeatureName>Screen(),
)
class <FeatureName>Route extends GoRouteData {
  // Optional: route parameters
}
```

### 3b. Add RouteGuard (if auth required)

```dart
@TypedGoRoute(
  path: '/<feature>',
  builder: (context, state) => const <FeatureName>Screen(),
)
class <FeatureName>Route extends GoRouteData {
  @override
  Widget build(context, state) {
    final authState = context.read<AuthCubit>().stateValue;
    if (authState case AuthStateUnauthenticated()) {
      return const LoginScreen();
    }
    return const <FeatureName>Screen();
  }
}
```

---

## Step 4: Implement Cubit/States

### 4a. Create State (sealed class)

```dart
sealed class <FeatureName>State {
  const <FeatureName>State();
}

class <FeatureName>StateInitial extends <FeatureName>State {
  const <FeatureName>StateInitial();
}

class <FeatureName>StateLoading extends <FeatureName>State {
  const <FeatureName>StateLoading();
}

class <FeatureName>StateLoaded extends <FeatureName>State {
  const <FeatureName>StateLoaded(this.data);
  final <DataType> data;
}

class <FeatureName>StateFailed extends <FeatureName>State {
  const <FeatureName>StateFailed();
}
```

### 4b. Create Cubit

```dart
@lazySingleton
class <FeatureName>Cubit extends CubitSignal<<FeatureName>State> {
  <FeatureName>Cubit(this._repository, this._failureHandler)
      : super(initialState: const <FeatureName>StateInitial());

  final I<FeatureName>Repository _repository;
  final FailureHandler _failureHandler;

  Future<void> loadData() async {
    emit(const <FeatureName>StateLoading());
    await safeRun(
      action: () async {
        final result = await _repository.getData();
        result.fold(
          (failure) => emit(const <FeatureName>StateFailed()),
          (data) => emit(<FeatureName>StateLoaded(data)),
        );
      },
      onException: _failureHandler.handleException,
    );
  }
}
```

---

## Step 5: Create Domain Entities

### 5a. Create Entity

```dart
base class <EntityName> {
  const <EntityName>({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}
```

### 5b. Create Value Objects (if needed)

```dart
base class <ValueObjectName> {
  const <ValueObjectName>(this.value);

  final String value;

  bool get isValid => value.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is <ValueObjectName> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
```

---

## Step 6: Define Repository Interface

```dart
interface class I<FeatureName>Repository {
  Future<TaskResult<List<<EntityName>>>> getAll();
  Future<TaskResult<<EntityName>>> getById(String id);
  Future<TaskResult<void>> create(<EntityName> entity);
  Future<TaskResult<void>> update(<EntityName> entity);
  Future<TaskResult<void>> delete(String id);
}
```

---

## Step 7: Implement Repository

```dart
@LazySingleton(as: I<FeatureName>Repository)
class <FeatureName>Repository implements I<FeatureName>Repository {
  <FeatureName>Repository(this._client);

  final Client _client;

  @override
  Future<TaskResult<List<<EntityName>>>> getAll() async {
    return TaskResult.tryCatch(() async {
      final results = await _client.<endpoint>.getAll();
      return results.map((dto) => dto.toEntity()).toList();
    });
  }

  // ... other methods
}
```

---

## Step 8: Create DTOs

```dart
@freezed
class <EntityName>DTO with _$<EntityName>DTO {
  const factory <EntityName>DTO({
    required String id,
    required String name,
  }) = _<EntityName>DTO;

  const <EntityName>DTO._();

  factory <EntityName>DTO.fromJson(Map<String, dynamic> json) =>
      _$<EntityName>DTOFromJson(json);

  <EntityName> toEntity() => <EntityName>(
        id: id,
        name: name,
      );
}
```

---

## Step 9: Add i18n Keys

In `lib/l10n/`:

```arb
{
  "featureNameTitle": "Feature Name",
  "featureNameLoading": "Loading...",
  "featureNameError": "Something went wrong",
  "featureNameSuccess": "Success!"
}
```

---

## Step 10: Run Codegen

```bash
# 1. Localization
slang

# 2. Freezed, Injectable, Chopper
dart run build_runner build --delete-conflicting-outputs

# 3. Serverpod (if models changed)
serverpod generate
```

---

## Dependency Injection

Register in `lib/app/injection/injection.dart`:

```dart
@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.allReady();
  getIt.init();
}

// Cubits registered via BlocSignalProvider in widget tree
// Repositories registered as LazySingleton via injectable
```