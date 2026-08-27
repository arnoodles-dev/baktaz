# Testing — Advanced Patterns

This file contains advanced testing patterns extracted from the original `testing.md` and additional guidance.

---

## Advanced Mocking Strategies

### Repository Mock with TaskResult

```dart
class MockIUserRepository extends Mock implements IUserRepository {}

late final MockIUserRepository mockUserRepository;

setUpAll(() {
  mockUserRepository = MockIUserRepository();
  getIt.registerLazySingleton<IUserRepository>(() => mockUserRepository);
});

group('UserCubit', () {
  test('emits [loading, loaded] when repository returns success', () async {
    // Arrange
    when(() => mockUserRepository.getUser(any()))
        .thenAnswer((_) async => TaskResult.right(testUser));

    // Act & Assert
    await expectLater(
      cubit.stream,
      emitsInOrder([
        const UserState.loading(),
        UserState.loaded(testUser),
      ]),
    );
  });

  test('emits [loading, failed] when repository returns failure', () async {
    // Arrange
    when(() => mockUserRepository.getUser(any()))
        .thenAnswer((_) async => TaskResult.left(
              Failure.server(StatusCode.http404, 'User not found'),
            ));

    // Act & Assert
    await expectLater(
      cubit.stream,
      emitsInOrder([
        const UserState.loading(),
        const UserState.failed(), // generic flag, not Failure
      ]),
    );
  });
});
```

### Mocking Serverpod Client

```dart
class MockClient extends Mock implements Client {}

late final MockClient mockClient;

setUpAll(() {
  mockClient = MockClient();
  when(() => mockClient.<endpoint>.<method>(any()))
      .thenAnswer((_) async => expectedResponse);
});
```

---

## Stream Testing with fake_async

```dart
test('search debounces and emits results', () async {
  fakeAsync((async) {
    final searchBloc = SearchBlocSignal(mockSearchRepository);

    // Act
    searchBloc.handleEvent(SearchStarted('query'));
    async.elapse(const Duration(milliseconds: 300));

    // Assert
    verify(() => mockSearchRepository.search('query')).called(1);
  });
});
```

---

## BlocSignal Testing

```dart
group('CounterCubit', () {
  late final CounterCubit cubit;

  setUp(() {
    cubit = CounterCubit();
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is 0', () {
    expect(cubit.stateValue, 0);
  });

  test('increment emits next state', () async {
    cubit.increment();

    await Future.delayed(Duration.zero); // allow state propagation

    expect(cubit.stateValue, 1);
  });

  test('state stream emits values', () async {
    final states = <int>[];

    cubit.stream.listen(states.add);
    cubit.increment();
    cubit.increment();
    cubit.increment();

    await Future.delayed(Duration.zero);

    expect(states, [1, 2, 3]);
  });
});
```

---

## Serverpod Session Testing

```dart
group('UserEndpoint', () {
  late final UserEndpoint endpoint;
  late final Session session;

  setUp(() async {
    session = await sessionBuilder.build();
    endpoint = UserEndpoint();
  });

  test('getUser returns user when exists', () async {
    // Seed test data
    final userId = await seedTestUser(session);

    // Act
    final result = await endpoint.getUser(session, userId);

    // Assert
    expect(result, isNotNull);
    expect(result!.id, userId);
  });

  test('getUser throws ApiException when not found', () async {
    // Act & Assert
    expect(
      () => endpoint.getUser(session, 'nonexistent'),
      throwsA(isA<ApiException>()),
    );
  });
});
```

---

## Golden Test Maintenance

### Updating Goldens

```bash
flutter test --update-goldens
```

### Golden Versioning

Goldens should be versioned by date. Update version in test:

```dart
void main() {
  setUpAll(() {
    // Golden version: YYYY-MM-DD
    goldenVersion = DateTime(2024, 1, 15);
  });

  testWidgets('renders correctly', goldenTest('/path/to/golden'));
}
```

### Jaspr Testing Patterns (Site)

```dart
group('Jaspr Component Tests', () {
  test('renders content', () {
    final document = renderComponent(MyComponent());
    expect(document.text, contains('Expected Text'));
  });
});
```

---

## Error Handling Testing

### Testing safeRun

```dart
test('safeRun returns false on exception and calls onException', () async {
  bool exceptionCalled = false;

  final result = await safeRun(
    action: () async => throw Exception('Test error'),
    onException: (e, s) => exceptionCalled = true,
  );

  expect(result, false);
  expect(exceptionCalled, true);
});

test('safeRun returns true on success', () async {
  final result = await safeRun(
    action: () async {},
    onException: (_, __) {},
  );

  expect(result, true);
});

test('safeRun swallows CancelledError', () async {
  bool exceptionCalled = false;

  final result = await safeRun(
    action: () async => throw CancelledError(),
    onException: (e, s) => exceptionCalled = true,
  );

  expect(result, false);
  expect(exceptionCalled, false); // NOT called
});
```

### Testing FailureHandler

```dart
test('FailureHandler routes ServerFailure(http404) to onNotFoundError', () {
  final actions = MockErrorActions();
  final handler = FailureHandler(FakeTalker());

  handler.handleFailure(
    Failure.server(StatusCode.http404, 'Not found'),
    actions,
  );

  verify(() => actions.onNotFoundError('Not found')).called(1);
});

test('FailureHandler routes UnexpectedFailure to onGenericError', () {
  final actions = MockErrorActions();
  final handler = FailureHandler(FakeTalker());

  handler.handleFailure(
    Failure.unexpected('Unexpected'),
    actions,
  );

  verify(() => actions.onGenericError(any())).called(1);
});
```

---

## Coverage Exclusions

Add to `.coverage_exclude`:

```
# Generated files
**/*.g.dart
**/*.freezed.dart
**/*.config.dart
**/*.chopper.dart

# Test utilities
test/utils/**
test/integration/**

# Widget wrappers
lib/app/widgets/**
```