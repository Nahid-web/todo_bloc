import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/routes/auth_routes.dart';
import '../../features/todo/routes/todo_routes.dart';
import '../../features/dashboard/routes/dashboard_routes.dart';
import '../../features/settings/routes/settings_routes.dart';

GoRouter createAppRouter(ValueNotifier<User?> authNotifier) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.value != null;
      final goingToLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !goingToLogin) {
        return '/login';
      }
      if (isLoggedIn && goingToLogin) {
        return '/';
      }
      return null;
    },
    routes: [
      ...authRoutes,
      ...dashboardRoutes,
      ...todoRoutes,
      ...settingsRoutes,
    ],
  );
}
