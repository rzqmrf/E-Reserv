// ============================================================
// auth_service.dart
// TODO (backend): sambungkan ke endpoint Laravel
// ============================================================

import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  // Session user yang sedang login (in-memory)
  static User? _currentUser;
  static bool _isLoggedIn = false;

  static User? get currentUser => _currentUser;
  static bool get isLoggedIn => _isLoggedIn;

  // TODO: POST /api/login
  static Future<void> login({required String email, required String password}) async {
    // Ganti dengan:
    // final res = await ApiService.post('/login', {'email': email, 'password': password});
    // ApiService.setToken(res['token']);
    // _currentUser = User.fromJson(res['user']);
    // _isLoggedIn = true;

    await Future.delayed(const Duration(seconds: 1));

    // Dummy user setelah login
    _currentUser = User(
      id: 1,
      name: 'Budi Santoso',
      email: email,
      phone: '081234567890',
      createdAt: DateTime.now(),
    );
    _isLoggedIn = true;
  }

  // TODO: POST /api/register
  static Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    // Ganti dengan:
    // final res = await ApiService.post('/register', {
    //   'name': name, 'email': email, 'phone': phone, 'password': password,
    // });
    // ApiService.setToken(res['token']);
    // _currentUser = User.fromJson(res['user']);
    // _isLoggedIn = true;

    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User(
      id: 1,
      name: name,
      email: email,
      phone: phone,
      createdAt: DateTime.now(),
    );
    _isLoggedIn = true;
  }

  // TODO: POST /api/logout
  static Future<void> logout() async {
    // await ApiService.post('/logout', {});
    ApiService.clearToken();
    _currentUser = null;
    _isLoggedIn = false;
  }

  // TODO: GET /api/user
  static Future<User?> getProfile() async {
    // final res = await ApiService.get('/user');
    // _currentUser = User.fromJson(res['data']);
    // return _currentUser;

    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }
}
