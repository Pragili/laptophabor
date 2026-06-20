import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_constants.dart';
import '../data/cart_repository.dart';
import '../domain/cart_item.dart';

final cartProvider =
    AsyncNotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends AsyncNotifier<List<CartItem>> {
  CartRepository get _repo => ref.read(cartRepositoryProvider);

  @override
  Future<List<CartItem>> build() => _repo.getCart();

  Future<void> add(int productId, {int quantity = 1}) async {
    await _repo.add(productId, quantity: quantity);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateQty(int itemId, int quantity) async {
    await _repo.updateQty(itemId, quantity);
    ref.invalidateSelf();
    await future;
  }

  Future<void> remove(int itemId) async {
    await _repo.remove(itemId);
    ref.invalidateSelf();
    await future;
  }

  Future<void> clear() async {
    await _repo.clear();
    ref.invalidateSelf();
    await future;
  }

  Future<Map<String, dynamic>> checkout(int addressId, String method) async {
    final order = await _repo.checkout(addressId, method);
    ref.invalidateSelf();
    return order;
  }
}

/// Derived totals — computed in the state layer, not the widget (SoC).
final cartSummaryProvider = Provider<CartSummary>((ref) {
  final items = ref.watch(cartProvider).valueOrNull ?? [];
  final subtotal = items.fold<double>(0, (s, i) => s + i.lineTotal);
  final count = items.fold<int>(0, (s, i) => s + i.quantity);
  if (subtotal == 0) return const CartSummary(0, 0, 0, 0, 0);
  final tax = subtotal * AppConstants.taxRate;
  const shipping = AppConstants.shippingFlat;
  return CartSummary(subtotal, tax, shipping, subtotal + tax + shipping, count);
});

class CartSummary {
  final double subtotal, tax, shipping, total;
  final int count;
  const CartSummary(this.subtotal, this.tax, this.shipping, this.total, this.count);
}
