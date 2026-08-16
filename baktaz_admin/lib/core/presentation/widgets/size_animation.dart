import 'package:flutter/material.dart';

class SizeAnimation extends CurvedAnimation {
  SizeAnimation({required super.parent})
    : super(
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOutCubicEmphasized),
        reverseCurve: Interval(0, 0.2, curve: Curves.easeInOutCubicEmphasized.flipped),
      );
}

class OffsetAnimation extends CurvedAnimation {
  OffsetAnimation({required super.parent})
    : super(
        curve: const Interval(0.4, 1, curve: Curves.easeInOutCubicEmphasized),
        reverseCurve: Interval(0, 0.2, curve: Curves.easeInOutCubicEmphasized.flipped),
      );
}
