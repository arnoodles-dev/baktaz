# State Management — Code Examples

This file contains extracted code examples from the original `state-management-architecture.md`.

---

## CubitSignal Implementation

### Correct: AuthCubit with Pattern B

```dart
/// ✅ CORRECT — @lazySingleton, initialState: named param, Pattern B error handling
@lazySingleton
class AuthCubit extends CubitSignal<AuthState> {
  AuthCubit(this._repository, this._failureHandler)
      : super(initialState: const AuthState.initial());

  final IAuthRepository _repository;
  final FailureHandler _failureHandler;

  Future<void> login(String email, String password) async {
    final result = await safeRun(
      action: () async => emit(await _repository.login(email, password)),
      onException: _failureHandler.handleException,
    );
    if (result) {
      // Success: state updated via action()
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState.unauthenticated());
  }
}
```

### Correct: AccountCubit with Computed

```dart
@lazySingleton
class AccountCubit extends CubitSignal<AccountState> {
  AccountCubit(this._accountRepository)
      : super(initialState: const AccountState.loading());

  final IAccountRepository _accountRepository;

  Future<void> loadAccount() async {
    final result = await _accountRepository.getAccount();
    result.fold(
      (failure) => emit(AccountState.error(failure.message)),
      (account) => emit(AccountState.loaded(account)),
    );
  }
}
```

---

## BlocSignal Implementation

### Correct: SearchBlocSignal

```dart
@lazySingleton
class SearchBlocSignal extends BlocSignal<SearchEvent, SearchState> {
  SearchBlocSignal(this._searchRepository)
      : super(initialState: const SearchState.initial());

  final ISearchRepository _searchRepository;

  @override
  Future<SearchState> handleEvent(SearchEvent event) async {
    return switch (event) {
      SearchStarted(:final query) => _handleSearch(query),
      SearchCleared() => const SearchState.initial(),
    };
  }

  Future<SearchState> _handleSearch(String query) async {
    emit(const SearchState.loading(query: query));
    final result = await _searchRepository.search(query);
    return result.fold(
      (failure) => SearchState.error(failure.message, query: query),
      (results) => SearchState.loaded(results, query: query),
    );
  }
}
```

---

## HookWidget Examples

### useSignalValue

```dart
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final authState = useSignalValue(authCubit.state);
    return Text('Logged in: ${authState.isAuthenticated}');
  }
}
```

### useSignalEffect

```dart
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // Navigation on auth state change
    useSignalEffect(() {
      if (authCubit.stateValue case AuthStateLoggedIn()) {
        context.go('/dashboard');
      }
    });
    return const SizedBox();
  }
}
```

### useComputed

```dart
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useSignalValue(counterCubit.state);
    final doubled = useComputed(() => count.value * 2);
    return Text('Doubled: ${doubled.value}');
  }
}
```

---

## Provider Examples

### BlocSignalBuilder

```dart
BlocSignalBuilder<AuthCubit, AuthState>(
  bloc: authCubit,
  builder: (context, state) {
    return switch (state) {
      AuthStateInitial() => const SplashScreen(),
      AuthStateLoading() => const LoadingIndicator(),
      AuthStateLoggedIn() => const HomeScreen(),
      AuthStateFailed() => const LoginScreen(),
    };
  },
)
```

### BlocSignalListener

```dart
BlocSignalListener<AuthCubit, AuthState>(
  listenWhen: (prev, curr) => curr is AuthStateFailed,
  listener: (context, state) {
    showErrorSnackBar(context, 'Login failed');
  },
  child: ...,
)
```

### BlocSignalConsumer

```dart
BlocSignalConsumer<AuthCubit, AuthState>(
  listenWhen: (prev, curr) => curr is AuthStateFailed,
  listener: (context, state) {
    showErrorSnackBar(context, 'Login failed');
  },
  builder: (context, state) {
    return switch (state) {
      AuthStateInitial() => const SplashScreen(),
      _ => const LoginScreen(),
    };
  },
)
```

### BlocSignalProvider.value (lazySingleton)

```dart
// In main.dart / provider setup
BlocSignalProvider.value(
  value: getIt<AuthCubit>(),
  child: MyApp(),
)
```

### BlocSignalProvider.create (injectable factory)

```dart
// In main.dart / provider setup
BlocSignalProvider(
  create: (_) => getIt<AccountCubit>(),
  child: MyApp(),
)
```

---

## Common Mistakes

### Creating signals in build()

```dart
// ❌ WRONG — creates new signal every build
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = signal(0);        // FAIL: creates new signal every build
    final derived = computed(() => count.value * 2);  // FAIL
    return Text('${count.value}');
  }
}

// ✅ CORRECT — initialize outside build
late final _count = signal(0);
late final _doubled = computed(() => _count.value * 2);
```

### Calling Cubit after dispose

```dart
// ❌ WRONG — may run after dispose
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<SomeCubit>().doSomething();  // FAIL: may run after dispose
      },
      child: const Text('Click'),
    );
  }
}

// ✅ CORRECT — check mounted
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (context.mounted) {
          context.read<SomeCubit>().doSomething();
        }
      },
      child: const Text('Click'),
    );
  }
}
```

### setState during build

```dart
// ❌ WRONG — triggers setState during build
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final TextEditingController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.text = displayValue;  // FAIL: triggers setState during build
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}

// ✅ CORRECT — postFrameCallback
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _controller.text = displayValue;
  });
}
```