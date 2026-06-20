import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../catalog/domain/product.dart';

final wishlistRepositoryProvider =
    Provider<WishlistRepository>((ref) => WishlistRepository(ref.read(dioProvider)));

final wishlistProvider =
    AsyncNotifierProvider<WishlistNotifier, List<Product>>(WishlistNotifier.new);

class WishlistRepository {
  final Dio _dio;
  WishlistRepository(this._dio);

  Future<List<Product>> list() async {
    final res = await _dio.get('/wishlist');
    return (res.data['data'] as List)
        .map((e) => Product.fromJson(e['product']))
        .toList();
  }

  Future<bool> toggle(int productId) async {
    final res = await _dio.post('/wishlist/toggle', data: {'productId': productId});
    return res.data['inWishlist'] == true;
  }
}

class WishlistNotifier extends AsyncNotifier<List<Product>> {
  WishlistRepository get _repo => ref.read(wishlistRepositoryProvider);

  @override
  Future<List<Product>> build() => _repo.list();

  Future<void> toggle(int productId) async {
    await _repo.toggle(productId);
    ref.invalidateSelf();
    await future;
  }

  bool contains(int productId) =>
      (state.valueOrNull ?? []).any((p) => p.id == productId);
}
