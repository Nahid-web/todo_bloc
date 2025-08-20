import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../navigation/presentation/pages/main_navigation_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'auth_page.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(AuthStarted()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(body: LoadingWidget());
          } else if (state is AuthAuthenticated) {
            return BlocProvider.value(
              value: context.read<AuthBloc>(),
              child: const MainNavigationPage(),
            );
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}
