// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:bloc_signals/bloc_signals.dart';
import 'package:flutter/widgets.dart';

extension CubitExt<S> on BlocSignalBase<S> {
  void safeEmit(S state) {
    if (isClosed) return;
    emit(state);
  }

  Future<bool> safeRun({
    required FutureOr<void> Function() action,
    required void Function(Exception, StackTrace?) onException,
    ValueChanged<bool>? onLoading,
  }) async {
    try {
      onLoading?.call(true);

      final FutureOr<void> result = action();

      if (result is Future) {
        await result;
      }
      return true;
    } on Exception catch (error, stackTrace) {
      onException(error, stackTrace);
      return false;
    } finally {
      onLoading?.call(false);
    }
  }
}
