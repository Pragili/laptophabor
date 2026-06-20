import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';
import '../data/auth_repository.dart';
import '../../../core/config/dev_config.dart';
import '../domain/user_entity.dart';

final authProvider =
    AsyncNotifierProvider<AuthNotifier, UserEntity?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<UserEntity?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);
  SecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  Future<UserEntity?> build() async {
    // Session restore on startup — never throw out of build().
    String? token;
    try {
      token = await _storage.readToken();
    } catch (_) {
      return null; // storage unavailable -> treat as logged out
    }
    if (token == null) return null;
    try {
      return await _repo.me();
    } catch (_) {
      try { await _storage.clear(); } catch (_) {}
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final r = await _repo.login(email, password);
      await _saveTokenSafe(r.token);
      return r.user;
    });
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final r = await _repo.register(name, email, password);
      await _saveTokenSafe(r.token);
      return r.user;
    });
  }

  // Persisting the token must never block a successful auth (e.g. if web
  // secure storage is unavailable, the session still works in memory).
  Future<void> _saveTokenSafe(String token) async {
    try {
      await _storage.saveToken(token);
    } catch (_) {/* non-fatal */}
  }

  /// One-tap demo entry: sets a logged-in demo user without touching the
  /// network or secure storage. Used by the "continue in demo mode" button so
  /// nothing in the request/auth chain can block testing.
  void enterDemo({bool admin = false}) {
    state = AsyncData(admin
        ? UserEntity(
            id: 1,
            fullName: 'Demo Admin',
            email: 'admin@laptopharbor.com',
            role: 'admin',
          )
        : UserEntity(
            id: 2,
            fullName: 'Demo User',
            email: 'demo@laptopharbor.com',
            role: 'customer',
          ));
  }

  Future<void> logout() async {
    try { await _storage.clear(); } catch (_) {}
    state = const AsyncData(null);
  }

  bool get isLoggedIn => state.valueOrNull != null;
}
