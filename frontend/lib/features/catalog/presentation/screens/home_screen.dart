import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../../domain/product.dart';
import '../catalog_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredProvider);
    final categories = ref.watch(categoriesProvider);
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(featuredProvider);
            ref.invalidate(categoriesProvider);
          },
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              Expanded(
                child: Text('Hi, ${user?.fullName.split(' ').first ?? 'there'} 👋',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => context.push(RouteNames.notifications),
              ),
            ]),
            const SizedBox(height: 12),
            // Search entry
            GestureDetector(
              onTap: () => context.go(RouteNames.search),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(children: const [
                  Icon(Icons.search, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text('Search laptops...', style: TextStyle(color: AppColors.textSecondary)),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            // Promo banner -> Mega Sale (discounted laptops)
            GestureDetector(
              onTap: () {
                ref.read(filterProvider.notifier).showSale();
                context.push(RouteNames.listing);
              },
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Mega Sale',
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Up to 30% off — tap to shop deals',
                              style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 10),
                          _ShopDealsPill(),
                        ],
                      ),
                    ),
                    const Icon(Icons.local_offer, color: Colors.white24, size: 64),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Categories', onSeeAll: () { ref.read(filterProvider.notifier).showAll(); context.push(RouteNames.listing); }),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: categories.when(
                data: (cats) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cats.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ActionChip(
                    label: Text(cats[i].name),
                    onPressed: () {
                      ref.read(filterProvider.notifier).showCategory(cats[i].id);
                      context.push(RouteNames.listing);
                    },
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Failed to load categories'),
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Featured', onSeeAll: () { ref.read(filterProvider.notifier).showAll(); context.push(RouteNames.listing); }),
            const SizedBox(height: 8),
            featured.when(
              data: (list) => _FeaturedGrid(products: list),
              loading: () => const SizedBox(
                  height: 200, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => const Text('Could not load products. Is the API running?'),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}

class _FeaturedGrid extends StatelessWidget {
  final List<Product> products;
  const _FeaturedGrid({required this.products});
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.62, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemBuilder: (_, i) => ProductCard(
        product: products[i],
        onTap: () => context.push('${RouteNames.product}/${products[i].id}'),
      ),
    );
  }
}

class _ShopDealsPill extends StatelessWidget {
  const _ShopDealsPill();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text('Shop deals',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      TextButton(onPressed: onSeeAll, child: const Text('See all')),
    ]);
  }
}
