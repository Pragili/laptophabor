import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_constants.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.tokenKey, value: token);
  Future<String?> readToken() => _storage.read(key: AppConstants.tokenKey);
  Future<void> clear() => _storage.delete(key: AppConstants.tokenKey);
}
