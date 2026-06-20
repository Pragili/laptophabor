import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/product_card.dart';
import '../data/wishlist_repository.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: wishlist.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(
            icon: Icons.cloud_off, title: 'Could not load wishlist'),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.favorite_border,
                title: 'No saved items',
                subtitle: 'Tap the heart on a product to save it here.',
                actionLabel: 'Browse',
                onAction: () => context.go(RouteNames.home))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.62,
                    crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemBuilder: (_, i) => ProductCard(
                  product: items[i],
                  wishlisted: true,
                  onWishlist: () => ref.read(wishlistProvider.notifier).toggle(items[i].id),
                  onTap: () => context.push('${RouteNames.product}/${items[i].id}'),
                ),
              ),
      ),
    );
  }
}
