import 'package:flutter/material.dart';

import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../todo/presentation/pages/todo_list_page.dart';
import 'package:go_router/go_router.dart';

class MainNavigationPage extends StatefulWidget {
  final Widget child;

  const MainNavigationPage({super.key, required this.child});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const NavigationDestination(
      icon: Icon(Icons.list_outlined),
      selectedIcon: Icon(Icons.list),
      label: 'Todos',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onItemSelected(context, index),
        destinations: _destinations,
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith('/todos')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onItemSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/todos');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }
}
