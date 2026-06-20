import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_image.dart';
import '../../../shared/widgets/empty_state.dart';

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final Dio dio = ref.read(dioProvider);
  final res = await dio.get('/admin/dashboard');
  return res.data as Map<String, dynamic>;
});

const _statusColors = {
  'pending': AppColors.warning,
  'paid': AppColors.info,
  'processing': AppColors.info,
  'shipped': AppColors.primary,
  'delivered': AppColors.success,
  'cancelled': AppColors.error,
};

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardProvider),
          ),
        ],
      ),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(
            icon: Icons.lock_outline,
            title: 'Access denied',
            subtitle: 'Sign in with an admin account to view metrics.'),
        data: (d) {
          final m = (d['metrics'] ?? {}) as Map;
          final series = (d['salesSeries'] as List?) ?? const [];
          final recent = (d['recentOrders'] as List?) ?? const [];
          final low = (d['lowStockProducts'] as List?) ?? const [];

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Overview', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('Store performance at a glance',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),

                // ---- metric cards ----
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _MetricCard(label: 'Revenue', value: money(m['revenue']),
                        icon: Icons.payments_outlined, color: AppColors.success,
                        caption: 'all-time, net of cancellations'),
                    _MetricCard(label: 'Orders', value: '${m['orders'] ?? 0}',
                        icon: Icons.receipt_long_outlined, color: AppColors.primary,
                        caption: 'placed to date'),
                    _MetricCard(label: 'Customers', value: '${m['users'] ?? 0}',
                        icon: Icons.people_alt_outlined, color: AppColors.info,
                        caption: 'registered accounts'),
                    _MetricCard(label: 'Low stock', value: '${m['lowStock'] ?? 0}',
                        icon: Icons.warning_amber_outlined, color: AppColors.warning,
                        caption: 'items at or below 5'),
                  ],
                ),
                const SizedBox(height: 20),

                // ---- revenue chart ----
                if (series.isNotEmpty) ...[
                  _Card(
                    title: 'Revenue · last 7 days',
                    child: _RevenueChart(series: series.cast<Map>()),
                  ),
                  const SizedBox(height: 20),
                ],

                // ---- recent orders ----
                _Card(
                  title: 'Recent orders',
                  child: recent.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('No orders yet.',
                              style: TextStyle(color: AppColors.textSecondary)))
                      : Column(
                          children: [
                            for (final o in recent.cast<Map>()) _OrderRow(order: o),
                          ],
                        ),
                ),
                const SizedBox(height: 20),

                // ---- low stock ----
                _Card(
                  title: 'Low stock alerts',
                  child: low.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('All products are well stocked.',
                              style: TextStyle(color: AppColors.textSecondary)))
                      : Column(
                          children: [
                            for (final p in low.cast<Map>()) _LowStockRow(product: p),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value, caption;
  final IconData icon;
  final Color color;
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<Map> series;
  const _RevenueChart({required this.series});

  @override
  Widget build(BuildContext context) {
    final values = series.map((s) => (s['value'] as num).toDouble()).toList();
    final maxV = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxV <= 0 ? 1.0 : maxV;

    return SizedBox(
      height: 170,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final s in series)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(_compact((s['value'] as num).toDouble()),
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor:
                              (((s['value'] as num).toDouble() / safeMax).clamp(0.04, 1.0)).toDouble(),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [AppColors.primary, AppColors.primaryDark],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${s['label']}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _compact(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);
}

class _OrderRow extends StatelessWidget {
  final Map order;
  const _OrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = (order['status'] ?? 'pending').toString();
    final color = _statusColors[status] ?? AppColors.textSecondary;
    final code = order['trackingCode'] ?? '#${order['id'] ?? ''}';
    final customer =
        (order['customer'] ?? order['user']?['fullName'] ?? 'Customer').toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceAlt,
            child: Text(
              customer.isNotEmpty ? customer[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('$code',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(money(order['total']),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(status.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LowStockRow extends StatelessWidget {
  final Map product;
  const _LowStockRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final stock = (product['stockQty'] ?? 0) as int;
    final critical = stock <= 2;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: AppImage(product['thumbnailUrl']?.toString()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('${product['title']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (critical ? AppColors.error : AppColors.warning)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$stock left',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: critical ? AppColors.error : AppColors.warning)),
          ),
        ],
      ),
    );
  }
}
