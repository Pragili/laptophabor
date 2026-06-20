import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/order.dart';

final orderRepositoryProvider =
    Provider<OrderRepository>((ref) => OrderRepository(ref.read(dioProvider)));

final myOrdersProvider = FutureProvider<List<OrderModel>>(
    (ref) => ref.read(orderRepositoryProvider).myOrders());

class OrderRepository {
  final Dio _dio;
  OrderRepository(this._dio);

  Future<List<OrderModel>> myOrders() async {
    final res = await _dio.get('/orders');
    return (res.data['data'] as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel> order(int id) async {
    final res = await _dio.get('/orders/$id');
    return OrderModel.fromJson(res.data['data']);
  }
}
