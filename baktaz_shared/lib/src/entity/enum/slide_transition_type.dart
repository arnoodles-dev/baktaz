import 'dart:ui' show Offset;

enum SlideTransitionType {
  topToBottom(Offset(0, -1)),
  bottomToTop(Offset(0, 1)),
  leftToRight(Offset(-1, 0)),
  rightToLeft(Offset(1, 0));

  const SlideTransitionType(this.offset);

  final Offset offset;
}
