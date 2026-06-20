import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/catalog_repository.dart';
import '../domain/product.dart';
import '../domain/product_filters.dart';

final featuredProvider = FutureProvider<List<Product>>(
    (ref) => ref.read(catalogRepositoryProvider).featured());

final categoriesProvider = FutureProvider<List<Category>>(
    (ref) => ref.read(catalogRepositoryProvider).categories());

final brandsProvider = FutureProvider<List<Brand>>(
    (ref) => ref.read(catalogRepositoryProvider).brands());

final productDetailProvider = FutureProvider.family<Product, int>(
    (ref, id) => ref.read(catalogRepositoryProvider).product(id));

/// Mutable filter state for the listing screen.
final filterProvider =
    NotifierProvider<FilterNotifier, ProductFilters>(FilterNotifier.new);

class FilterNotifier extends Notifier<ProductFilters> {
  @override
  ProductFilters build() => const ProductFilters();

  void setCategory(int? id) => state = state.copyWith(categoryId: id);
  void setQuery(String q) => state = state.copyWith(query: q);
  void setSort(String s) => state = state.copyWith(sort: s);
  void setPrice(double min, double max) =>
      state = state.copyWith(minPrice: min, maxPrice: max);
  void setMinRating(double r) => state = state.copyWith(minRating: r);
  void setOnSale(bool v) => state = state.copyWith(onSale: v);

  // Fresh-filter entry points used from Home
  void showSale() => state = const ProductFilters(onSale: true);
  void showCategory(int id) => state = ProductFilters(categoryId: id);
  void showAll() => state = const ProductFilters();
  void setCpu(String? c) => state = state.copyWith(cpu: c);

  void toggleBrand(int id) {
    final s = {...state.brandIds};
    s.contains(id) ? s.remove(id) : s.add(id);
    state = state.copyWith(brandIds: s);
  }

  void toggleRam(int gb) {
    final s = {...state.ram};
    s.contains(gb) ? s.remove(gb) : s.add(gb);
    state = state.copyWith(ram: s);
  }

  void toggleStorage(int gb) {
    final s = {...state.storage};
    s.contains(gb) ? s.remove(gb) : s.add(gb);
    state = state.copyWith(storage: s);
  }

  void reset() => state = ProductFilters(categoryId: state.categoryId);
}

/// Re-fetches whenever filters change.
final productListProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  final filters = ref.watch(filterProvider);
  return ref.read(catalogRepositoryProvider).products(filters);
});
