import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/nav_extensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/primary_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String code;
  const OrderSuccessScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 96),
            const SizedBox(height: 16),
            Text('Order Confirmed!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Your tracking code is $code',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            PrimaryButton(
                label: 'View My Orders',
                onPressed: () => context.go(RouteNames.orders)),
            const SizedBox(height: 12),
            TextButton(
                onPressed: () => context.goTab(RouteNames.home),
                child: const Text('Continue shopping')),
          ]),
        ),
      ),
    );
  }
}
