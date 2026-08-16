import 'package:baktaz_admin/core/presentation/widgets/size_animation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RailTransition extends HookWidget {
  const RailTransition({required this.animation, required this.backgroundColor, required this.child, super.key});

  final Animation<double> animation;
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool ltr = Directionality.of(context) == TextDirection.ltr;

    final Animation<double> widthAnimation = useMemoized(
      () => Tween<double>(begin: 0, end: 1).animate(SizeAnimation(parent: animation)),
      <Object>[],
    );

    final Animation<Offset> offsetAnimation = useMemoized(
      () => Tween<Offset>(
        begin: ltr ? const Offset(-1, 0) : const Offset(1, 0),
        end: Offset.zero,
      ).animate(OffsetAnimation(parent: animation)),
      <Object>[animation, ltr],
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) => ClipRect(
        child: DecoratedBox(
          decoration: BoxDecoration(color: backgroundColor),
          child: Align(
            alignment: Alignment.topLeft,
            widthFactor: widthAnimation.value,
            child: FractionalTranslation(translation: offsetAnimation.value, child: child),
          ),
        ),
      ),
      child: child,
    );
  }
}
