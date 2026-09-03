import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/core/domain/cubit/theme/theme_cubit.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DarkModeScreen extends StatelessWidget {
  const DarkModeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colorScheme.surface,
    appBar: BaktazAppBar(
      title: 'Dark Mode',
      leading: BackButton(color: context.colorScheme.onSurface, onPressed: () => GoRouter.of(context).pop()),
    ),
    body: Padding(
      padding: Paddings.horizontalLarge,
      child: BaktazListRow(
        label: context.i18n.settings.follow_system,
        subtitle: context.i18n.settings.dark_mode_subtitle,
        trailing: Transform.scale(
          scale: 0.8,
          child: BaktazToggle(
            value: context.read<ThemeCubit>().isDarkMode,
            onChanged: (_) => context.read<ThemeCubit>().switchTheme(Theme.of(context).brightness),
          ),
        ),
      ),
    ),
  );
}
