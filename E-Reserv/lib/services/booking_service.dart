// ============================================================
// booking_service.dart
// TODO (backend): sambungkan ke endpoint Laravel
// ============================================================

import '../models/booking.dart';
import 'api_service.dart';

class BookingService {
  // TODO: POST /api/bookings
  // POST /api/bookings
  static Future<Booking> create({
    required int fieldId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required int durationHours,
    required int totalPrice,
  }) async {
    final res = await ApiService.post('/bookings', {
      'field_id': fieldId,
      'date': date.toIso8601String().split('T').first,
      'start_time': startTime,
      'end_time': endTime,
      'duration_hours': durationHours,
      'total_price': totalPrice,
    });
    return Booking.fromJson(res['data'] ?? res);
  }

  // GET /api/bookings
  static Future<List<Booking>> getMyBookings() async {
    final res = await ApiService.get('/bookings');
    final List data = res is List ? res : (res['data'] ?? []);
    return data.map((e) => Booking.fromJson(e)).toList();
  }

  // GET /api/bookings/{id}
  static Future<Booking> getById(int id) async {
    final res = await ApiService.get('/bookings/$id');
    return Booking.fromJson(res['data'] ?? res);
  }
}

// ── Dummy data (hapus setelah backend siap) ──────────────────
final List<Booking> _dummyBookings = [];
