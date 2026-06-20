import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/dev_config.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../cart/presentation/cart_notifier.dart';
import 'settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- account ----
          _Section(title: 'Account', children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryTint,
                child: Text(
                  (user?.fullName.isNotEmpty ?? false)
                      ? user!.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
              title: Text(user?.fullName ?? 'Guest'),
              subtitle: Text(user?.email ?? ''),
            ),
          ]),

          // ---- notifications ----
          _Section(title: 'Notifications', children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Order updates'),
              subtitle: const Text('Status changes and delivery alerts'),
              value: settings.orderUpdates,
              onChanged: notifier.setOrderUpdates,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Promotions & offers'),
              subtitle: const Text('Deals, discounts and product launches'),
              value: settings.promotions,
              onChanged: notifier.setPromotions,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Email me receipts'),
              value: settings.emailReceipts,
              onChanged: notifier.setEmailReceipts,
            ),
          ]),

          // ---- support ----
          _Section(title: 'Support', children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.help_outline, color: AppColors.primary),
              title: const Text('Help & FAQ'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => context.push(RouteNames.faq),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications_none, color: AppColors.primary),
              title: const Text('Notifications inbox'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => context.push(RouteNames.notifications),
            ),
          ]),

          // ---- data ----
          _Section(title: 'Data', children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.remove_shopping_cart_outlined,
                  color: AppColors.warning),
              title: const Text('Clear cart'),
              subtitle: const Text('Remove all items from your cart'),
              onTap: () => _confirmClearCart(context, ref),
            ),
          ]),

          // ---- about ----
          _Section(title: 'About', children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Version'),
              trailing: Text('1.0.0', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Backend mode'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (kUseMockBackend ? AppColors.warning : AppColors.success)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  kUseMockBackend ? 'Demo (mock)' : 'Live (API)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kUseMockBackend ? AppColors.warning : AppColors.success,
                  ),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text('Log Out', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(RouteNames.login);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _confirmClearCart(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('This removes all items from your cart.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(cartProvider.notifier).clear();
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cart cleared')));
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary, letterSpacing: 0.4)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
