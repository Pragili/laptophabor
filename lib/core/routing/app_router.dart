import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_notifier.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/catalog/presentation/screens/home_screen.dart';
import '../../features/catalog/presentation/screens/product_listing_screen.dart';
import '../../features/catalog/presentation/screens/product_details_screen.dart';
import '../../features/catalog/presentation/screens/search_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/cart/presentation/screens/order_success_screen.dart';
import '../../features/wishlist/presentation/wishlist_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/support/presentation/faq_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/main_shell.dart';
import 'route_names.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: RouteNames.splash,
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      // While the session is still resolving, stay on splash.
      if (auth.isLoading) return null;
      final loggedIn = auth.valueOrNull != null;
      final loc = state.matchedLocation;

      const publicRoutes = {
        RouteNames.splash, RouteNames.login,
        RouteNames.register, RouteNames.forgot,
      };
      final onPublic = publicRoutes.contains(loc);

      if (!loggedIn && !onPublic) return RouteNames.login;
      if (loggedIn && (loc == RouteNames.login || loc == RouteNames.splash)) {
        return RouteNames.home;
      }
      // Admin guard
      if (loc.startsWith(RouteNames.adminDashboard) &&
          auth.valueOrNull?.isAdmin != true) {
        return RouteNames.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: RouteNames.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: RouteNames.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: RouteNames.forgot, builder: (_, __) => const ForgotPasswordScreen()),

      // Shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) =>
            MainShell(currentIndex: _indexFor(state.matchedLocation), child: child),
        routes: [
          GoRoute(path: RouteNames.home, builder: (_, __) => const HomeScreen()),
          GoRoute(path: RouteNames.search, builder: (_, __) => const SearchScreen()),
          GoRoute(path: RouteNames.cart, builder: (_, __) => const CartScreen()),
          GoRoute(path: RouteNames.wishlist, builder: (_, __) => const WishlistScreen()),
          GoRoute(path: RouteNames.profile, builder: (_, __) => const ProfileScreen()),
          GoRoute(path: RouteNames.settings, builder: (_, __) => const SettingsScreen()),
        ],
      ),

      // Full-screen routes (outside the shell)
      GoRoute(path: RouteNames.listing, parentNavigatorKey: _rootKey,
          builder: (_, __) => const ProductListingScreen()),
      GoRoute(
        path: '${RouteNames.product}/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            ProductDetailsScreen(productId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: RouteNames.checkout, parentNavigatorKey: _rootKey,
          builder: (_, __) => const CheckoutScreen()),
      GoRoute(
        path: RouteNames.orderSuccess,
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            OrderSuccessScreen(code: state.uri.queryParameters['code'] ?? ''),
      ),
      GoRoute(path: RouteNames.orders, parentNavigatorKey: _rootKey,
          builder: (_, __) => const OrdersScreen()),
      GoRoute(path: RouteNames.notifications, parentNavigatorKey: _rootKey,
          builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: RouteNames.faq, parentNavigatorKey: _rootKey,
          builder: (_, __) => const FaqScreen()),
      GoRoute(path: RouteNames.adminDashboard, parentNavigatorKey: _rootKey,
          builder: (_, __) => const AdminDashboardScreen()),
    ],
  );
});

int _indexFor(String location) {
  if (location.startsWith(RouteNames.search)) return 1;
  if (location.startsWith(RouteNames.cart)) return 2;
  if (location.startsWith(RouteNames.wishlist)) return 3;
  if (location.startsWith(RouteNames.profile)) return 4;
  if (location.startsWith(RouteNames.settings)) return 5;
  return 0;
}

/// Bridges Riverpod auth state changes to GoRouter's refresh mechanism.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
