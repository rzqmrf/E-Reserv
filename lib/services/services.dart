import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

// ─── API SERVICE (Base) ───────────────────────────────────────
class ApiService {
  // TODO: ganti dengan URL Laravel
  static const String baseUrl = 'http://127.0.0.1:8000/api';
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
    final res = await http.get(Uri.parse('$baseUrl$endpoint'), headers: _headers);
    return _handle(res);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$baseUrl$endpoint'), headers: _headers, body: jsonEncode(body));
    return _handle(res);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final res = await http.put(Uri.parse('$baseUrl$endpoint'), headers: _headers, body: jsonEncode(body));
    return _handle(res);
  }

  static dynamic _handle(http.Response res) {
    if (kDebugMode) print('[API] ${res.statusCode} ${res.request?.url}');
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    if (res.statusCode == 401) throw Exception('Sesi habis, silakan login ulang');
    throw Exception(body['message'] ?? 'Terjadi kesalahan');
  }
}

// ─── AUTH SERVICE ─────────────────────────────────────────────
class AuthService {
  static User? _currentUser;
  static bool _isLoggedIn = false;

  static User? get currentUser => _currentUser;
  static bool get isLoggedIn => _isLoggedIn;

  // TODO: POST /api/login
  static Future<void> login({required String email, required String password}) async {
    // final res = await ApiService.post('/login', {'email': email, 'password': password});
    // ApiService.setToken(res['token']);
    // _currentUser = User.fromJson(res['user']);
    // _isLoggedIn = true;
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(id: 1, name: 'Budi Santoso', email: email, phone: '081234567890', createdAt: DateTime.now());
    _isLoggedIn = true;
  }

  // TODO: POST /api/register
  static Future<void> register({required String name, required String email, required String phone, required String password}) async {
    // final res = await ApiService.post('/register', {'name': name, 'email': email, 'phone': phone, 'password': password});
    // ApiService.setToken(res['token']);
    // _currentUser = User.fromJson(res['user']);
    // _isLoggedIn = true;
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(id: 1, name: name, email: email, phone: phone, createdAt: DateTime.now());
    _isLoggedIn = true;
  }

  // TODO: POST /api/logout
  static Future<void> logout() async {
    ApiService.clearToken();
    _currentUser = null;
    _isLoggedIn = false;
  }

  // TODO: GET /api/user
  static Future<User?> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser;
  }
}

// ─── FIELD SERVICE ────────────────────────────────────────────
class FieldService {
  // TODO: GET /api/fields
  static Future<List<Field>> getAll() async {
    // final res = await ApiService.get('/fields');
    // return (res['data'] as List).map((e) => Field.fromJson(e)).toList();
    await Future.delayed(const Duration(milliseconds: 800));
    return dummyFields;
  }

  // TODO: GET /api/fields/{id}
  static Future<Field> getById(int id) async {
    // final res = await ApiService.get('/fields/$id');
    // return Field.fromJson(res['data']);
    await Future.delayed(const Duration(milliseconds: 300));
    return dummyFields.firstWhere((f) => f.id == id);
  }
}

// ─── SLOT SERVICE ─────────────────────────────────────────────
class SlotService {
  // TODO: GET /api/fields/{fieldId}/slots?date=YYYY-MM-DD
  static Future<List<Slot>> getByFieldAndDate(int fieldId, DateTime date) async {
    // final dateStr = date.toIso8601String().split('T').first;
    // final res = await ApiService.get('/fields/$fieldId/slots?date=$dateStr');
    // return (res['data'] as List).map((e) => Slot.fromJson(e)).toList();
    await Future.delayed(const Duration(milliseconds: 600));
    final field = dummyFields.firstWhere((f) => f.id == fieldId, orElse: () => dummyFields.first);
    return generateDummySlots(fieldId, date, field.capacity);
  }
}

// ─── BOOKING SERVICE ──────────────────────────────────────────
class BookingService {
  // TODO: POST /api/bookings
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
    // final res = await ApiService.post('/bookings', {
    //   'field_id': fieldId, 'slot_id': slotId,
    //   'date': date.toIso8601String().split('T').first,
    //   'start_time': startTime, 'end_time': endTime,
    //   'duration_hours': durationHours, 'total_price': totalPrice,
    //   'person_count': personCount,
    // });
    // return Booking.fromJson(res['data']);
    await Future.delayed(const Duration(seconds: 1));
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch,
      bookingCode: 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      userId: AuthService.currentUser?.id ?? 1,
      fieldId: fieldId, slotId: slotId, date: date,
      startTime: startTime, endTime: endTime,
      durationHours: durationHours, totalPrice: totalPrice,
      personCount: personCount, status: BookingStatus.pending,
      createdAt: DateTime.now(),
      field: dummyFields.firstWhere((f) => f.id == fieldId),
    );
    bookingHistory.insert(0, booking);
    return booking;
  }

  // TODO: GET /api/bookings
  static Future<List<Booking>> getMyBookings() async {
    // final res = await ApiService.get('/bookings');
    // return (res['data'] as List).map((e) => Booking.fromJson(e)).toList();
    await Future.delayed(const Duration(milliseconds: 600));
    return bookingHistory;
  }
}

// ─── PAYMENT SERVICE ──────────────────────────────────────────
class PaymentService {
  // TODO: POST /api/payments → dapat snap_token dari Midtrans
  static Future<String> getSnapToken(int bookingId, int amount) async {
    // final res = await ApiService.post('/payments', {'booking_id': bookingId, 'amount': amount});
    // return res['snap_token'];
    await Future.delayed(const Duration(seconds: 1));
    return 'dummy-snap-token-${DateTime.now().millisecondsSinceEpoch}';
  }
}
