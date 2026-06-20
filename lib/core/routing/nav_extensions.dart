import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension TabNav on BuildContext {
  /// Navigate to a bottom-nav tab from anywhere. If the current screen is a
  /// full-screen page pushed on top of the shell (product, checkout, order
  /// success, orders…), pop it first so switching tabs is actually visible.
  void goTab(String location) {
    final router = GoRouter.of(this);
    if (router.canPop()) router.pop();
    router.go(location);
  }
}
