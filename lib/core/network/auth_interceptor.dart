import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

/// Centralises JWT attachment so screens never touch the token directly (SoC).
class AuthInterceptor extends Interceptor {
  final SecureStorage storage;
  AuthInterceptor(this.storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await storage.readToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    } catch (_) {
      // Storage unavailable (e.g. on web): proceed unauthenticated rather than
      // failing the whole request.
    }
    handler.next(options);
  }
}
