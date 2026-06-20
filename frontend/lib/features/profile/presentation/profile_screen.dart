import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_image.dart';
import '../../auth/presentation/auth_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;

    Widget tile(IconData icon, String label, VoidCallback onTap, {Color? color}) =>
        ListTile(
          leading: Icon(icon, color: color ?? AppColors.primary),
          title: Text(label, style: TextStyle(color: color)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: onTap,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(children: [
        const SizedBox(height: 12),
        Center(
          child: Column(children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryTint,
              backgroundImage: appImageProvider(user?.avatarUrl),
              child: appImageProvider(user?.avatarUrl) == null
                  ? const Icon(Icons.person, size: 40, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(user?.fullName ?? 'Guest',
                style: Theme.of(context).textTheme.titleLarge),
            Text(user?.email ?? '',
                style: const TextStyle(color: AppColors.textSecondary)),
          ]),
        ),
        const SizedBox(height: 20),
        tile(Icons.receipt_long_outlined, 'My Orders', () => context.push(RouteNames.orders)),
        tile(Icons.favorite_border, 'Wishlist', () => context.go(RouteNames.wishlist)),
        tile(Icons.notifications_none, 'Notifications', () => context.push(RouteNames.notifications)),
        tile(Icons.help_outline, 'Help & FAQ', () => context.push(RouteNames.faq)),
        if (user?.isAdmin == true)
          tile(Icons.admin_panel_settings_outlined, 'Admin Dashboard',
              () => context.push(RouteNames.adminDashboard), color: AppColors.secondaryDark),
        const Divider(),
        tile(Icons.logout, 'Log Out', () async {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) context.go(RouteNames.login);
        }, color: AppColors.error),
      ]),
    );
  }
}
