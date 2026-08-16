import 'package:baktaz_admin/app/generated/localization.g.dart';
import 'package:baktaz_admin/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

export 'package:baktaz_shared/src/extensions/base_build_context_ext.dart';

extension BuildContextExt on BuildContext {
  I18n get i18n => read<AppLocalizationCubit>().stateValue;

  GoRouter get goRouter => GoRouter.of(this);
}
