import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/main_layout.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/savings/presentation/savings_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../core/placeholder_screen.dart';

import '../../features/revenues/presentation/add_revenue_screen.dart';
import '../../features/expenses/presentation/add_expense_screen.dart';
import '../../features/savings/presentation/add_saving_screen.dart';
import '../../features/transactions/domain/transaction.dart';
import '../../features/savings/domain/saving.dart';
import '../../features/debts/presentation/debts_screen.dart';
import '../../features/claims/presentation/claims_screen.dart';
import '../../features/debts/domain/debt.dart';
import '../../features/claims/domain/claim.dart';
import '../../features/debts/presentation/add_debt_screen.dart';
import '../../features/claims/presentation/add_claim_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    // refreshListenable: ValueNotifier(authState), // Not ideal for AsyncValue, simplified approach below using redirect
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull ?? false;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return '/login';
      }

      if (isLoggingIn && isLoggedIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/add-revenue',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddRevenueScreen(transaction: state.extra as Transaction?),
      ),
      GoRoute(
        path: '/add-expense',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddExpenseScreen(transaction: state.extra as Transaction?),
      ),
      GoRoute(
        path: '/add-saving',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddSavingScreen(saving: state.extra as Saving?),
      ),
      GoRoute(
        path: '/debts',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DebtsScreen(),
      ),
      GoRoute(
        path: '/claims',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ClaimsScreen(),
      ),
      GoRoute(
        path: '/add-debt',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddDebtScreen(debt: state.extra as Debt?),
      ),
      GoRoute(
        path: '/add-claim',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddClaimScreen(claim: state.extra as Claim?),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/savings',
                builder: (context, state) => const SavingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

