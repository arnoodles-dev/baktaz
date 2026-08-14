import 'package:fpdart/fpdart.dart';

// ignore: prefer-match-file-name
extension EitherExt<L, R> on Either<L, R> {
  R asRight() => (this as Right<L, R>).value;
  L asLeft() => (this as Left<L, R>).value;
}

extension OptionExt<T> on Option<T> {
  T asSome() => (this as Some<T>).value;
}
