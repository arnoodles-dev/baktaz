import 'dart:async';

import 'package:baktaz_shared/src/mixin/bloc_signal_presentation_mixin.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/widgets.dart';

/// Listens to one-shot presentation events from a [BlocSignalBase] with [BlocSignalPresentationMixin].
class BlocSignalPresentationListener<B extends BlocSignalPresentationMixin<Event, dynamic>, Event>
    extends StatefulWidget {
  const BlocSignalPresentationListener({required this.listener, this.bloc, this.child, super.key});

  final B? bloc;
  final void Function(BuildContext context, Event event) listener;
  final Widget? child;

  @override
  State<BlocSignalPresentationListener<B, Event>> createState() => _BlocSignalPresentationListenerState<B, Event>();
}

class _BlocSignalPresentationListenerState<B extends BlocSignalPresentationMixin<Event, dynamic>, Event>
    extends State<BlocSignalPresentationListener<B, Event>> {
  StreamSubscription<Event>? _subscription;
  B? _resolvedBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final B bloc = widget.bloc ?? context.read<B>();
    if (_resolvedBloc != bloc) {
      _unsubscribe();
      _resolvedBloc = bloc;
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = _resolvedBloc?.presentationStream.listen((Event event) {
      if (mounted) widget.listener(context, event);
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child ?? const SizedBox.shrink();
}
