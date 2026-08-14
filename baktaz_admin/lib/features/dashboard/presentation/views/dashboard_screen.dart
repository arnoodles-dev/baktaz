import 'dart:async';

import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_admin/features/dashboard/domain/cubit/dashboard/dashboard_cubit.dart';
import 'package:baktaz_admin/features/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:baktaz_client/baktaz_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (BuildContext context, AuthState state) => state.maybeWhen(
      authenticated: (Account account) => BlocProvider<DashboardCubit>(
        create: (_) {
          final DashboardCubit cubit = getIt<DashboardCubit>();
          unawaited(cubit.initialize());
          return cubit;
        },
        child: DashboardContent(account: account),
      ),
      orElse: () => const Center(child: CircularProgressIndicator()),
    ),
  );
}
