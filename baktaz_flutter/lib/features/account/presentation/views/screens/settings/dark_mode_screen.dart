import 'package:baktaz_flutter/core/domain/cubit/theme/theme_cubit.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/settings_option.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DarkModeScreen extends StatelessWidget {
  const DarkModeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colorScheme.surface,
    appBar: BaktazAppBar(
      title: SettingsOption.darkMode.name.camelToSentence(),
      leading: BackButton(color: context.colorScheme.onSurface, onPressed: () => GoRouter.of(context).pop()),
    ),
    body: Padding(
      padding: Paddings.horizontalLarge,
      child: BaktazListRow(
        label: 'Follow system settings',
        subtitle: "Turn on Dark mode when your device's Dark mode setting is on",
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
