import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/dev_config.dart';
import '../config/env.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';
import 'mock_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Accept': 'application/json'},
  ));
  dio.interceptors.add(AuthInterceptor(ref.read(secureStorageProvider)));
  // DEV BYPASS: serve everything from an in-memory mock backend (no server needed).
  if (kUseMockBackend) dio.interceptors.add(MockInterceptor());
  return dio;
});
