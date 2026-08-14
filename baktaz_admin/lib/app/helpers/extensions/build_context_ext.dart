import 'package:baktaz_admin/app/generated/localization.g.dart';
import 'package:baktaz_admin/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

export 'package:baktaz_shared/src/extensions/base_build_context_ext.dart';

extension BuildContextExt on BuildContext {
  I18n get i18n => read<AppLocalizationCubit>().state;

  GoRouter get goRouter => GoRouter.of(this);
}
