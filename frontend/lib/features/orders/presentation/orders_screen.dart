import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/nav_extensions.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/order_repository.dart';
import '../domain/order.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  static const _statusColors = {
    'pending': AppColors.warning,
    'paid': AppColors.info,
    'processing': AppColors.info,
    'shipped': AppColors.primary,
    'delivered': AppColors.success,
    'cancelled': AppColors.error,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(icon: Icons.cloud_off, title: 'Could not load orders'),
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                subtitle: 'Your placed orders will appear here.',
                actionLabel: 'Shop now',
                onAction: () => context.goTab(RouteNames.home))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _OrderCard(order: list[i], color: _statusColors[list[i].status] ?? AppColors.textSecondary),
              ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final Color color;
  const _OrderCard({required this.order, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('#${order.trackingCode ?? order.id}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(order.status.toUpperCase(),
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 6),
        Text('${order.items.length} item(s) · ${shortDate(order.createdAt)}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        Text(money(order.total),
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
      ]),
    );
  }
}
