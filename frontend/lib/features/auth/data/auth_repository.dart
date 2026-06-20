import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/user_entity.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.read(dioProvider)));

class AuthResult {
  final String token;
  final UserEntity user;
  AuthResult(this.token, this.user);
}

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);

  Future<AuthResult> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    return AuthResult(res.data['token'], UserEntity.fromJson(res.data['user']));
  }

  Future<AuthResult> register(String fullName, String email, String password) async {
    final res = await _dio.post('/auth/register',
        data: {'fullName': fullName, 'email': email, 'password': password});
    return AuthResult(res.data['token'], UserEntity.fromJson(res.data['user']));
  }

  Future<UserEntity> me() async {
    final res = await _dio.get('/auth/me');
    return UserEntity.fromJson(res.data['user']);
  }

  Future<void> forgotPassword(String email) =>
      _dio.post('/auth/forgot-password', data: {'email': email});
}
