import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/notification_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              ref.invalidate(notificationsProvider);
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notifs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(icon: Icons.cloud_off, title: 'Could not load'),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none, title: 'No notifications')
            : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: list[i].isRead
                        ? AppColors.surfaceAlt
                        : AppColors.primaryTint,
                    child: Icon(Icons.notifications,
                        color: list[i].isRead ? AppColors.textSecondary : AppColors.primary),
                  ),
                  title: Text(list[i].title,
                      style: TextStyle(
                          fontWeight: list[i].isRead ? FontWeight.w400 : FontWeight.w600)),
                  subtitle: list[i].body == null ? null : Text(list[i].body!),
                ),
              ),
      ),
    );
  }
}
