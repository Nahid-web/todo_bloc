import 'package:go_router/go_router.dart';

import '../presentation/pages/auth_page.dart';

final authRoutes = [
  GoRoute(
    path: '/login',
    builder: (context, state) => const AuthPage(),
  ),
];
