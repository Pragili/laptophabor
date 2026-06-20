import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routing/nav_extensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/price_tag.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../../cart/presentation/cart_notifier.dart';
import '../../domain/product.dart';
import '../catalog_providers.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final int productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    return Scaffold(
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load product.\n$e')),
        data: (p) => CustomScrollView(slivers: [
          SliverAppBar(
            expandedHeight: 320, pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: _Gallery(images: p.images, fallback: p.thumbnailUrl),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${(p.brandName ?? '').toUpperCase()} · ${p.categoryName ?? ''}',
                    style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 4),
                Text(p.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                RatingStars(rating: p.ratingAvg, count: p.ratingCount),
                const SizedBox(height: 12),
                Row(children: [
                  PriceTag(price: p.price, salePrice: p.salePrice, size: 24),
                  const Spacer(),
                  _StockPill(inStock: p.inStock),
                ]),
                const SizedBox(height: 20),
                _SpecsTable(product: p),
                if (p.description != null) ...[
                  const SizedBox(height: 20),
                  Text('Description', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(p.description!,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
                const SizedBox(height: 20),
                Text('Reviews (${p.ratingCount})',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (p.reviews.isEmpty)
                  const Text('No reviews yet.', style: TextStyle(color: AppColors.textSecondary)),
                ...p.reviews.map((r) => _ReviewCard(review: r)),
                const SizedBox(height: 90),
              ]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (p) => _AddToCartBar(product: p),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  final List<String> images;
  final String? fallback;
  const _Gallery({required this.images, this.fallback});
  @override
  Widget build(BuildContext context) {
    final imgs = images.isNotEmpty ? images : (fallback != null ? [fallback!] : <String>[]);
    if (imgs.isEmpty) {
      return Container(color: AppColors.surfaceAlt,
          child: const Icon(Icons.laptop, size: 80, color: AppColors.border));
    }
    return PageView(
      children: [for (final ref in imgs) AppImage(ref, fit: BoxFit.cover)],
    );
  }
}

class _StockPill extends StatelessWidget {
  final bool inStock;
  const _StockPill({required this.inStock});
  @override
  Widget build(BuildContext context) {
    final c = inStock ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(inStock ? 'In stock' : 'Out of stock',
          style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

class _SpecsTable extends StatelessWidget {
  final Product product;
  const _SpecsTable({required this.product});
  @override
  Widget build(BuildContext context) {
    Widget row(String k, String? v) => v == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              SizedBox(width: 96,
                  child: Text(k, style: const TextStyle(color: AppColors.textSecondary))),
              Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w500))),
            ]),
          );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        row('CPU', product.cpu),
        row('RAM', product.ramGb == null ? null : '${product.ramGb} GB'),
        row('Storage', product.storageGb == null ? null : '${product.storageGb} GB'),
        row('Screen', product.screenSize == null ? null : '${product.screenSize}"'),
      ]),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic review;
  const _ReviewCard({required this.review});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
          const SizedBox(width: 8),
          Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          RatingStars(rating: review.rating.toDouble(), size: 13),
        ]),
        if (review.comment != null) ...[
          const SizedBox(height: 6),
          Text(review.comment),
        ],
      ]),
    );
  }
}

class _AddToCartBar extends ConsumerWidget {
  final Product product;
  const _AddToCartBar({required this.product});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          Expanded(
            child: PrimaryButton(
              label: product.inStock ? 'Add to Cart' : 'Out of stock',
              isCta: true,
              onPressed: product.inStock
                  ? () async {
                      await ref.read(cartProvider.notifier).add(product.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Added to cart'),
                        action: SnackBarAction(
                            label: 'View Cart',
                            onPressed: () => context.goTab(RouteNames.cart)),
                      ));
                    }
                  : null,
            ),
          ),
        ]),
      ),
    );
  }
}
