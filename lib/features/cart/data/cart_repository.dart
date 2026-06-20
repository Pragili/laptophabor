import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/cart_item.dart';

final cartRepositoryProvider =
    Provider<CartRepository>((ref) => CartRepository(ref.read(dioProvider)));

class CartRepository {
  final Dio _dio;
  CartRepository(this._dio);

  Future<List<CartItem>> getCart() async {
    final res = await _dio.get('/cart');
    return (res.data['data'] as List).map((e) => CartItem.fromJson(e)).toList();
  }

  Future<void> add(int productId, {int quantity = 1}) =>
      _dio.post('/cart', data: {'productId': productId, 'quantity': quantity});

  Future<void> updateQty(int itemId, int quantity) =>
      _dio.put('/cart/$itemId', data: {'quantity': quantity});

  Future<void> remove(int itemId) => _dio.delete('/cart/$itemId');

  Future<void> clear() => _dio.delete('/cart');

  Future<Map<String, dynamic>> checkout(int addressId, String paymentMethod) async {
    final res = await _dio.post('/orders/checkout',
        data: {'addressId': addressId, 'paymentMethod': paymentMethod});
    return res.data['data'];
  }
}
