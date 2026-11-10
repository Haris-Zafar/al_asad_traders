import 'package:al_asad_traders/app/app_shell.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/widgets/app_scaffold.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Provider for the application [GoRouter].
/// Rule: docs/ARCHITECTURE.md > Folders. Story: none.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  return createRouter();
});

/// Creates the application [GoRouter] instance.
/// Rule: docs/UI_PLAN.md > Navigation. Story: none.
GoRouter createRouter({String initialLocation = '/bills'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return AppShell(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/bills',
                builder: (BuildContext context, GoRouterState state) {
                  return const BillsTabScreen();
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'details',
                    builder: (BuildContext context, GoRouterState state) {
                      return const BillDetailsScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/demands',
                builder: (BuildContext context, GoRouterState state) {
                  return const DemandsTabScreen();
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'details',
                    builder: (BuildContext context, GoRouterState state) {
                      return const DemandDetailsScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/buyers',
                builder: (BuildContext context, GoRouterState state) {
                  return const BuyersTabScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/more',
                builder: (BuildContext context, GoRouterState state) {
                  return const MoreTabScreen();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Placeholder screen for the Bills tab.
class BillsTabScreen extends StatelessWidget {
  /// Creates a [BillsTabScreen].
  const BillsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: AppStrings.billsTab,
      body: KeyedSubtree(
        key: Key('bills_tab_screen'),
        child: SizedBox.shrink(),
      ),
    );
  }
}

/// Placeholder detail screen for testing sub-route navigation under Bills tab.
class BillDetailsScreen extends StatelessWidget {
  /// Creates a [BillDetailsScreen].
  const BillDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: AppStrings.billNumber,
      body: KeyedSubtree(
        key: Key('bill_details_screen'),
        child: SizedBox.shrink(),
      ),
    );
  }
}

/// Placeholder screen for the Demands tab.
class DemandsTabScreen extends StatelessWidget {
  /// Creates a [DemandsTabScreen].
  const DemandsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: AppStrings.demandsTab,
      body: KeyedSubtree(
        key: Key('demands_tab_screen'),
        child: SizedBox.shrink(),
      ),
    );
  }
}

/// Placeholder detail screen for testing sub-route navigation under Demands tab.
class DemandDetailsScreen extends StatelessWidget {
  /// Creates a [DemandDetailsScreen].
  const DemandDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: AppStrings.demand,
      body: KeyedSubtree(
        key: Key('demand_details_screen'),
        child: SizedBox.shrink(),
      ),
    );
  }
}

/// Placeholder screen for the Buyers tab.
class BuyersTabScreen extends StatelessWidget {
  /// Creates a [BuyersTabScreen].
  const BuyersTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: AppStrings.buyersTab,
      body: KeyedSubtree(
        key: Key('buyers_tab_screen'),
        child: SizedBox.shrink(),
      ),
    );
  }
}

/// Placeholder screen for the More tab.
class MoreTabScreen extends StatelessWidget {
  /// Creates a [MoreTabScreen].
  const MoreTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: AppStrings.moreTab,
      body: KeyedSubtree(key: Key('more_tab_screen'), child: SizedBox.shrink()),
    );
  }
}
