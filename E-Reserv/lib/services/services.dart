import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

// ─── API SERVICE (Base) ───────────────────────────────────────
class ApiService {
  // Samakan dengan api_service.dart
  static const String baseUrl = 'http://localhost:8000/api';
  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;
  static bool get hasToken => _token != null;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<dynamic> get(String endpoint) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl$endpoint'), headers: _headers);
      return _handle(res);
    } catch (e) {
      if (kDebugMode) print('[API ERROR] GET $endpoint: $e');
      rethrow;
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl$endpoint'), headers: _headers, body: jsonEncode(body));
      return _handle(res);
    } catch (e) {
      if (kDebugMode) print('[API ERROR] POST $endpoint: $e');
      rethrow;
    }
  }

  static dynamic _handle(http.Response res) {
    if (kDebugMode) print('[API] ${res.statusCode} ${res.request?.url}');
    
    // Jika response kosong
    if (res.body.isEmpty) throw Exception('Server mengirim response kosong');

    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    if (res.statusCode == 401) throw Exception('Sesi habis, silakan login ulang');
    throw Exception(body['message'] ?? 'Terjadi kesalahan server (${res.statusCode})');
  }
}

// ─── AUTH SERVICE ─────────────────────────────────────────────
class AuthService {
  static User? _currentUser;
  static bool _isLoggedIn = false;

  static User? get currentUser => _currentUser;
  static bool get isLoggedIn => _isLoggedIn;

  // POST /api/login
  static Future<void> login({required String email, required String password}) async {
    final res = await ApiService.post('/login', {'email': email, 'password': password});
    ApiService.setToken(res['token']);
    _currentUser = User.fromJson(res['user']);
    _isLoggedIn = true;
  }

  // POST /api/register
  static Future<void> register({required String name, required String email, required String phone, required String password}) async {
    final res = await ApiService.post('/register', {'name': name, 'email': email, 'phone': phone, 'password': password});
    ApiService.setToken(res['token']);
    _currentUser = User.fromJson(res['user']);
    _isLoggedIn = true;
  }

  // POST /api/logout
  static Future<void> logout() async {
    try {
      await ApiService.post('/logout', {});
    } catch (e) {
      // ignore
    } finally {
      ApiService.clearToken();
      _currentUser = null;
      _isLoggedIn = false;
    }
  }

  // GET /api/user
  static Future<User?> getProfile() async {
    try {
      final res = await ApiService.get('/user');
      _currentUser = User.fromJson(res['data'] ?? res);
      _isLoggedIn = true;
      return _currentUser;
    } catch (e) {
      return null;
    }
  }
}

// ─── FIELD SERVICE ────────────────────────────────────────────
class FieldService {
  // GET /api/fields
  static Future<List<Field>> getAll() async {
    final res = await ApiService.get('/fields');
    final List data = res is List ? res : (res['data'] ?? []);
    return data.map((e) => Field.fromJson(e)).toList();
  }

  // GET /api/fields/{id}
  static Future<Field> getById(int id) async {
    final res = await ApiService.get('/fields/$id');
    return Field.fromJson(res['data'] ?? res);
  }
}

// ─── SLOT SERVICE ─────────────────────────────────────────────
class SlotService {
  // GET /api/fields/{fieldId}/slots?date=YYYY-MM-DD
  static Future<List<Slot>> getByFieldAndDate(int fieldId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;
    final res = await ApiService.get('/fields/$fieldId/slots?date=$dateStr');
    final List data = res is List ? res : (res['data'] ?? []);
    return data.map((e) => Slot.fromJson(e)).toList();
  }
}

// ─── BOOKING SERVICE ──────────────────────────────────────────
class BookingService {
  // POST /api/bookings
  static Future<Booking> create({
    required int fieldId,
    required int slotId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required int durationHours,
    required int totalPrice,
    required int personCount,
  }) async {
    final res = await ApiService.post('/bookings', {
      'field_id': fieldId, 
      'slot_id': slotId,
      'date': date.toIso8601String().split('T').first,
      'start_time': startTime, 
      'end_time': endTime,
      'duration_hours': durationHours, 
      'total_price': totalPrice,
      'person_count': personCount,
    });
    return Booking.fromJson(res['data'] ?? res);
  }

  // GET /api/bookings
  static Future<List<Booking>> getMyBookings() async {
    final res = await ApiService.get('/bookings');
    final List data = res is List ? res : (res['data'] ?? []);
    return data.map((e) => Booking.fromJson(e)).toList();
  }
}

// ─── PAYMENT SERVICE ──────────────────────────────────────────
class PaymentService {
  // POST /api/payments
  static Future<String> getSnapToken(int bookingId, int amount) async {
    final res = await ApiService.post('/payments/store', {'booking_id': bookingId, 'amount': amount});
    return res['snap_token'];
  }
}
