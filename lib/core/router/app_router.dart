import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';

/// Route paths as constants — avoids magic strings scattered through the
/// app when navigating (context.go(AppRoutes.dashboard) instead of
/// context.go('/dashboard')).
class AppRoutes {
  AppRoutes._();
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const products = '/products';
}

/// The router watches currentUserProvider and redirects automatically:
/// signed-out users can only reach /login; signed-in users are bounced
/// away from /login. Every feature screen gets this for free — no
/// per-screen "am I logged in?" checks needed.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !isLoggingIn) return AppRoutes.login;
      if (isLoggedIn && isLoggingIn) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      // ShellRoute would wrap these in the NavigationRail/Drawer shell for
      // desktop/tablet layouts — added when Dashboard module is built out.
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) => const ProductListScreen(),
      ),
    ],
  );
});
