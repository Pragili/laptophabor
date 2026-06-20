import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../auth_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // Wait for the auth session-restore to settle.
    await Future.delayed(const Duration(milliseconds: 1200));
    try {
      await ref.read(authProvider.future);
    } catch (_) {/* fall through to login */}
    if (!mounted) return;
    final user = ref.read(authProvider).valueOrNull;
    context.go(user == null ? RouteNames.login : RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.laptop_mac, size: 72, color: Colors.white),
          SizedBox(height: 16),
          Text('LaptopHarbor',
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
          SizedBox(height: 24),
          SizedBox(height: 26, width: 26,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4)),
        ]),
      ),
    );
  }
}
