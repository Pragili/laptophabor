import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/product_card.dart';
import '../catalog_providers.dart';

class ProductListingScreen extends ConsumerWidget {
  const ProductListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);
    final filters = ref.watch(filterProvider);

    return Scaffold(
      endDrawer: const _FilterDrawer(),
      appBar: AppBar(
        title: Text(filters.onSale ? 'Mega Sale' : 'Laptops'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: ref.read(filterProvider.notifier).setSort,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'newest', child: Text('Newest')),
              PopupMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
              PopupMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
              PopupMenuItem(value: 'rating', child: Text('Top Rated')),
              PopupMenuItem(value: 'popular', child: Text('Most Popular')),
            ],
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: Badge(
                isLabelVisible: filters.brandIds.isNotEmpty ||
                    filters.ram.isNotEmpty || filters.storage.isNotEmpty,
                child: const Icon(Icons.tune),
              ),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: products.when(
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.search_off,
                title: 'No matches',
                subtitle: 'Try adjusting your filters.')
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(productListProvider),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.62,
                      crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemBuilder: (_, i) => ProductCard(
                    product: list[i],
                    onTap: () => context.push('${RouteNames.product}/${list[i].id}'),
                  ),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(
            icon: Icons.cloud_off, title: 'Failed to load',
            subtitle: 'Check that the backend API is running.'),
      ),
    );
  }
}

class _FilterDrawer extends ConsumerWidget {
  const _FilterDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);
    final brands = ref.watch(brandsProvider);

    Widget chips(List<int> values, Set<int> selected, void Function(int) onTap, String unit) =>
        Wrap(spacing: 8, children: [
          for (final v in values)
            FilterChip(
              label: Text('$v$unit'),
              selected: selected.contains(v),
              onSelected: (_) => onTap(v),
            ),
        ]);

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Filters', style: Theme.of(context).textTheme.titleLarge),
              TextButton(onPressed: notifier.reset, child: const Text('Reset')),
            ]),
            const Divider(),
            const Text('Brand', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            brands.when(
              data: (bs) => Wrap(spacing: 8, children: [
                for (final b in bs)
                  FilterChip(
                    label: Text(b.name),
                    selected: filters.brandIds.contains(b.id),
                    onSelected: (_) => notifier.toggleBrand(b.id),
                  ),
              ]),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('—'),
            ),
            const SizedBox(height: 16),
            Text('Price: \$${filters.minPrice.toInt()} – \$${filters.maxPrice.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            RangeSlider(
              min: 0, max: 4000, divisions: 40,
              values: RangeValues(filters.minPrice, filters.maxPrice),
              labels: RangeLabels('\$${filters.minPrice.toInt()}', '\$${filters.maxPrice.toInt()}'),
              onChanged: (r) => notifier.setPrice(r.start, r.end),
            ),
            const SizedBox(height: 8),
            const Text('RAM', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            chips([8, 16, 32, 64], filters.ram, notifier.toggleRam, 'GB'),
            const SizedBox(height: 16),
            const Text('Storage', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            chips([256, 512, 1024, 2048], filters.storage, notifier.toggleStorage, 'GB'),
            const SizedBox(height: 16),
            const Text('Minimum rating', style: TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              min: 0, max: 5, divisions: 5, value: filters.minRating,
              label: filters.minRating.toString(),
              onChanged: notifier.setMinRating,
            ),
            const SizedBox(height: 16),
            FilterChip(
              label: const Text('On sale only'),
              selected: filters.onSale,
              onSelected: notifier.setOnSale,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.invalidate(productListProvider);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48)),
              child: const Text('Apply filters'),
            ),
          ]),
        ),
      ),
    );
  }
}
