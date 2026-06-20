import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/product.dart';
import '../domain/product_filters.dart';

final catalogRepositoryProvider =
    Provider<CatalogRepository>((ref) => CatalogRepository(ref.read(dioProvider)));

class CatalogRepository {
  final Dio _dio;
  CatalogRepository(this._dio);

  Future<List<Product>> products(ProductFilters f, {int page = 1}) async {
    final res = await _dio.get('/products', queryParameters: {...f.toQuery(), 'page': page});
    return (res.data['data'] as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> featured() async {
    final res = await _dio.get('/products/featured');
    return (res.data['data'] as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> product(int id) async {
    final res = await _dio.get('/products/$id');
    return Product.fromJson(res.data['data']);
  }

  Future<List<Category>> categories() async {
    final res = await _dio.get('/categories');
    return (res.data['data'] as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<List<Brand>> brands() async {
    final res = await _dio.get('/brands');
    return (res.data['data'] as List).map((e) => Brand.fromJson(e)).toList();
  }
}
