import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_bloc/firebase_options.dart';

import 'core/di/injector.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/bloc/theme_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependency injection
  await di.initDependencies();

  final authNotifier = ValueNotifier<User?>(null);
  FirebaseAuth.instance.authStateChanges().listen((user) {
    authNotifier.value = user;
  });

  runApp(MyApp(authNotifier: authNotifier));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<User?> authNotifier;

  const MyApp({super.key, required this.authNotifier});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ThemeBloc>(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Todo BLoC',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: createAppRouter(authNotifier),
          );
        },
      ),
    );
  }
}
