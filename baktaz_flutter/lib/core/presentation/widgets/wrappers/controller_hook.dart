import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

T useController<T>({required T controller}) => use<T>(_ControllerHook<T>(controller: controller));

class _ControllerHook<T> extends Hook<T> {
  const _ControllerHook({required this.controller, super.keys});

  final T controller;

  @override
  HookState<T, Hook<T>> createState() => _ControllerHookState<T>();
}

class _ControllerHookState<T> extends HookState<T, _ControllerHook<T>> {
  @override
  T build(BuildContext context) => hook.controller;

  @override
  void dispose() {
    try {
      // Add controllers that does not have dispose method
      if (hook.controller is CarouselSliderController) return;
      (hook.controller as dynamic)?.dispose();
      // ignore: avoid_catches_without_on_clauses
    } catch (error) {
      // do nothing
      // log intentionally omitted
    }
  }

  @override
  String get debugLabel => 'use${T.runtimeType}';
}
