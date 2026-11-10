import 'package:al_asad_traders/core/strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App shell widget containing the main bottom navigation bar with 4 tabs.
/// Rule: docs/UI_PLAN.md > Navigation. Story: none.
class AppShell extends StatelessWidget {
  /// Creates the 4-tab application shell.
  const AppShell({required this.navigationShell, super.key});

  /// The stateful navigation shell provided by GoRouter.
  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = GoRouter.of(context).canPop();
    final bool allowSystemPop = navigationShell.currentIndex == 0 && !canPop;

    return PopScope(
      canPop: allowSystemPop,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
        } else if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              key: Key('tab_bills'),
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: AppStrings.billsTab,
            ),
            NavigationDestination(
              key: Key('tab_demands'),
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: AppStrings.demandsTab,
            ),
            NavigationDestination(
              key: Key('tab_buyers'),
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: AppStrings.buyersTab,
            ),
            NavigationDestination(
              key: Key('tab_more'),
              icon: Icon(Icons.more_horiz_outlined),
              selectedIcon: Icon(Icons.more_horiz),
              label: AppStrings.moreTab,
            ),
          ],
        ),
      ),
    );
  }
}
