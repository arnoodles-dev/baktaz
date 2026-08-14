// ignore_for_file: prefer-match-file-name

import 'package:baktaz_shared/src/entity/failure.dart';
import 'package:fpdart/fpdart.dart';

/// A type definition for a synchronous result containing either a [Failure] or a value of type [T].
typedef Result<T> = Either<Failure, T>;

/// A type definition for an asynchronous result containing either a [Failure] or a value of type [T].
typedef TaskResult<T> = TaskEither<Failure, T>;

/// A type definition for standard JSON map.
typedef Json = Map<String, dynamic>;

extension ResultExt<T> on Result<T> {
  /// Unwraps the result if it is a `Right`, throwing the `Failure` if it is a `Left`.
  T getRightOrThrow() => fold((Failure failure) => throw Exception(failure.message), (T value) => value);
}
