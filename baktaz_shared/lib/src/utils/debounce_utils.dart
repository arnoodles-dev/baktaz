import 'dart:async';

class DebounceUtils<T> {
  DebounceUtils({this.milliseconds = 500});

  final int milliseconds;
  Timer? _timer;
  Completer<T>? _completer;

  Future<T> run(Future<T> Function() action) {
    _timer?.cancel();
    _completer ??= Completer<T>();
    final Completer<T> completer = _completer!;

    _timer = Timer(Duration(milliseconds: milliseconds), () async {
      try {
        final T result = await action();
        if (!completer.isCompleted) completer.complete(result);
      } on Exception catch (exception) {
        if (!completer.isCompleted) completer.completeError(exception);
      } finally {
        if (!completer.isCompleted) {
          completer.completeError('Debouncer timeout');
        }
      }
    });

    return completer.future;
  }

  void dispose() {
    _timer?.cancel();
    final Completer<T>? completer = _completer;
    if (completer != null && !completer.isCompleted) {
      completer.completeError('Debouncer disposed');
    }
    _completer = null;
  }
}
