import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart'; // For ValueNotifier

import '../../../features/auth/presentation/pages/auth_page.dart';
import '../../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../../features/navigation/presentation/pages/main_navigation_page.dart';
import '../../../features/settings/presentation/pages/settings_page.dart';
import '../../../features/todo/presentation/pages/todo_list_page.dart';
import '../../../features/todo/presentation/pages/add_edit_todo_page.dart';
import '../../../features/todo/presentation/pages/todo_detail_page.dart';

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
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigationPage(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/todos',
            builder: (context, state) => const TodoListPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddEditTodoPage(),
              ),
              GoRoute(
                path: 'edit/:todoId',
                builder: (context, state) => AddEditTodoPage(todoId: state.pathParameters['todoId']!),
              ),
              GoRoute(
                path: 'detail/:todoId',
                builder: (context, state) => TodoDetailPage(todoId: state.pathParameters['todoId']!),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}