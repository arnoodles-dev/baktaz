import 'package:baktaz_flutter/core/domain/cubit/hidable/hidable_cubit.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';

class Hidable extends StatelessWidget {
  const Hidable({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedAlign(
    alignment: Alignment.topCenter,
    duration: const Duration(milliseconds: 500),
    heightFactor: context.select<HidableCubit, bool>((HidableCubit cubit) => cubit.stateValue) ? 1.0 : 0.0,
    child: child,
  );
}
