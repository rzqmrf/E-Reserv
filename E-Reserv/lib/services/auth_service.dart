// ============================================================
// auth_service.dart
// ============================================================

import '../models/models.dart';
import 'api_service.dart';

class AuthService {
  static User? _currentUser;
  static bool _isLoggedIn = false;

  static User? get currentUser => _currentUser;
  static bool get isLoggedIn => _isLoggedIn;

  // Cek apakah user adalah admin
  static bool get isAdmin => _currentUser?.email == 'admin@gmail.com';

  // POST /api/login
  static Future<void> login(
      {required String email, required String password}) async {
    // 1. Validasi Client-side: Admin tidak boleh login via app ini
    if (email.toLowerCase() == 'admin@gmail.com') {
      throw Exception(
          'Akses ditolak: Admin tidak diperbolehkan login melalui aplikasi ini.');
    }

    final res = await ApiService.post('/login', {
      'email': email,
      'password': password,
    });

    ApiService.setToken(res['token']);
    _currentUser = User.fromJson(res['user']);
    _isLoggedIn = true;
  }

  // POST /api/register
  static Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    // Opsional: Cegah registrasi menggunakan email admin
    if (email.toLowerCase() == 'admin@gmail.com') {
      throw Exception('Email ini tidak dapat digunakan untuk registrasi.');
    }

    final res = await ApiService.post('/register', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });

    ApiService.setToken(res['token']);
    _currentUser = User.fromJson(res['user']);
    _isLoggedIn = true;
  }

  static Future<void> logout() async {
    try {
      await ApiService.post('/logout', {});
    } catch (e) {
      // Abaikan error
    } finally {
      ApiService.clearToken();
      _currentUser = null;
      _isLoggedIn = false;
    }
  }

  static Future<User?> getProfile() async {
    try {
      final res = await ApiService.get('/user');
      final user = User.fromJson(res['data'] ?? res);

      // 2. Validasi tambahan saat session check
      if (user.email == 'admin@gmail.com') {
        await logout();
        return null;
      }

      _currentUser = user;
      _isLoggedIn = true;
      return _currentUser;
    } catch (e) {
      _isLoggedIn = false;
      return null;
    }
  }
}
