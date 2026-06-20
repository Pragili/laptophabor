import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/address.dart';

final addressRepositoryProvider =
    Provider<AddressRepository>((ref) => AddressRepository(ref.read(dioProvider)));

final addressesProvider = FutureProvider<List<Address>>(
    (ref) => ref.read(addressRepositoryProvider).list());

class AddressRepository {
  final Dio _dio;
  AddressRepository(this._dio);

  Future<List<Address>> list() async {
    final res = await _dio.get('/addresses');
    return (res.data['data'] as List).map((e) => Address.fromJson(e)).toList();
  }

  Future<Address> create(Map<String, dynamic> body) async {
    final res = await _dio.post('/addresses', data: body);
    return Address.fromJson(res.data['data']);
  }
}
