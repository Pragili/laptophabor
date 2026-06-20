import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/dev_config.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class LaptopHarborApp extends ConsumerWidget {
  const LaptopHarborApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'LaptopHarbor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        if (!kUseMockBackend) return child ?? const SizedBox.shrink();
        // Thin ribbon so it's obvious the dev bypass (mock backend) is active.
        return Banner(
          message: 'DEMO',
          location: BannerLocation.topEnd,
          color: const Color(0xFFF59E0B),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
