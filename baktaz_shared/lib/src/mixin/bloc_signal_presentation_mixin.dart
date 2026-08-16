import 'dart:async';

import 'package:bloc_signals/bloc_signals.dart';

/// Adds one-shot presentation event broadcasting to any [BlocSignalBase].
mixin BlocSignalPresentationMixin<Event, State> on BlocSignalBase<State> {
  final StreamController<Event> _presentationController = StreamController<Event>.broadcast();

  /// Stream of one-shot presentation events.
  Stream<Event> get presentationStream => _presentationController.stream;

  /// Dispatches a one-shot presentation event to active UI listeners.
  void emitPresentation(Event event) {
    if (!isClosed) {
      _presentationController.add(event);
    }
  }

  @override
  Future<void> close() {
    _presentationController.close();
    return super.close();
  }
}
