import 'package:go_router/go_router.dart';

import '../../navigation/presentation/pages/main_navigation_page.dart';
import '../presentation/pages/dashboard_page.dart';

final dashboardRoutes = [
  ShellRoute(
    builder: (context, state, child) => MainNavigationPage(child: child),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  ),
];
