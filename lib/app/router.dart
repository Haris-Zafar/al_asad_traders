import 'package:al_asad_traders/app/app_shell.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/widgets/widgets.dart';
import 'package:al_asad_traders/features/auth_sync/providers/auth_provider.dart';
import 'package:al_asad_traders/features/auth_sync/providers/device_setup_provider.dart';
import 'package:al_asad_traders/features/auth_sync/ui/login_screen.dart';
import 'package:al_asad_traders/features/auth_sync/ui/setup_screen.dart';
import 'package:al_asad_traders/features/people/ui/business_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Provider for the application [GoRouter].
/// Rule: docs/ARCHITECTURE.md > Folders. Story: none.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  final AsyncValue<User?> authAsync = ref.watch(authStateProvider);
  final bool isLoggedIn = authAsync.value != null;
  final bool isSetupCompleted = ref.watch(deviceSetupCompletedProvider);

  return createRouter(
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggingIn = state.matchedLocation == '/login';
      final bool isSetup = state.matchedLocation == '/setup';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      if (isLoggedIn && !isSetupCompleted && !isSetup) {
        return '/setup';
      }
      if (isLoggedIn && isSetupCompleted && (isLoggingIn || isSetup)) {
        return '/bills';
      }
      return null;
    },
  );
});

/// Creates the application [GoRouter] instance.
/// Rule: docs/UI_PLAN.md > Navigation. Story: none.
GoRouter createRouter({
  String initialLocation = '/bills',
  String? Function(BuildContext, GoRouterState)? redirect,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    redirect: redirect,
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/setup',
        builder: (BuildContext context, GoRouterState state) {
          return const SetupScreen();
        },
      ),
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
                routes: <RouteBase>[
                  GoRoute(
                    path: 'business',
                    builder: (BuildContext context, GoRouterState state) {
                      return const BusinessProfileScreen();
                    },
                  ),
                ],
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

/// Screen for the More tab.
/// Rule: docs/UI_PLAN.md > Screens (/more). Story: S11.
class MoreTabScreen extends StatelessWidget {
  /// Creates a [MoreTabScreen].
  const MoreTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppStrings.moreTab,
      body: KeyedSubtree(
        key: const Key('more_tab_screen'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppListRow(
              key: const Key('more_business_row'),
              title: AppStrings.businessProfileTitle,
              onTap: () => context.go('/more/business'),
            ),
          ],
        ),
      ),
    );
  }
}
