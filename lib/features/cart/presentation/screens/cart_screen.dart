import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/quantity_stepper.dart';
import '../../domain/cart_item.dart';
import '../cart_notifier.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final summary = ref.watch(cartSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cart.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(
            icon: Icons.cloud_off, title: 'Could not load cart',
            subtitle: 'Make sure you are signed in and the API is running.'),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.shopping_cart_outlined,
                title: 'Your cart is empty',
                subtitle: 'Browse our catalog and add a laptop.',
                actionLabel: 'Shop now',
                onAction: () => context.go(RouteNames.home),
              )
            : Column(children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _CartRow(item: items[i]),
                  ),
                ),
                _CheckoutBar(total: summary.total, count: summary.count),
              ]),
      ),
    );
  }
}

class _CartRow extends ConsumerWidget {
  final CartItem item;
  const _CartRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 72, height: 72,
            child: AppImage(item.product.thumbnailUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.product.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(money(item.product.effectivePrice),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Row(children: [
              QuantityStepper(
                quantity: item.quantity,
                max: item.product.stockQty,
                onChanged: (q) => notifier.updateQty(item.id, q),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => notifier.remove(item.id),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final double total;
  final int count;
  const _CheckoutBar({required this.total, required this.count});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total ($count items)',
                style: Theme.of(context).textTheme.bodyMedium),
            Text(money(total),
                style: Theme.of(context).textTheme.titleLarge),
          ]),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Proceed to Checkout',
            isCta: true,
            onPressed: () => context.push(RouteNames.checkout),
          ),
        ]),
      ),
    );
  }
}
