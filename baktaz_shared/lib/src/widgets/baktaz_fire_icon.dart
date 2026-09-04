// ignore_for_file: avoid-returning-widgets

import 'package:baktaz_shared/src/theme/baktaz_custom_colors.dart';
import 'package:baktaz_shared/src/theme/baktaz_elevation.dart';
import 'package:flutter/material.dart';

/// FireIcon — DESIGN.md §1.11
///
/// Small flame icon using warning color. Optional subtle pulse animation.
class BaktazFireIcon extends StatefulWidget {
  const BaktazFireIcon({this.size = 16, this.pulse = false, super.key});

  final double size;
  final bool pulse;

  @override
  State<BaktazFireIcon> createState() => _BaktazFireIconState();
}

class _BaktazFireIconState extends State<BaktazFireIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: BaktazElevation.animationStepPulse, vsync: this);
    _animation = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.pulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BaktazFireIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulse && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _color {
    final BaktazCustomColors? customColors = Theme.of(context).extension<BaktazCustomColors>();
    return customColors?.warning ?? const Color(0xFFFFB800);
  }

  Widget get _icon => Icon(Icons.local_fire_department, size: widget.size, color: _color);

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse) {
      return _icon;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) => Transform.scale(scale: _animation.value, child: _icon),
    );
  }
}
