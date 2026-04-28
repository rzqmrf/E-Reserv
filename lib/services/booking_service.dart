// ============================================================
// booking_service.dart
// TODO (backend): sambungkan ke endpoint Laravel
// ============================================================

import '../models/booking.dart';
import 'api_service.dart';

class BookingService {
  // TODO: POST /api/bookings
  static Future<Booking> create({
    required int fieldId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required int durationHours,
    required int totalPrice,
  }) async {
    // Dummy - ganti dengan:
    // final res = await ApiService.post('/bookings', {
    //   'field_id': fieldId,
    //   'date': date.toIso8601String().split('T').first,
    //   'start_time': startTime,
    //   'end_time': endTime,
    //   'duration_hours': durationHours,
    //   'total_price': totalPrice,
    // });
    // return Booking.fromJson(res['data']);

    await Future.delayed(const Duration(seconds: 1));
    return Booking(
      id: DateTime.now().millisecondsSinceEpoch,
      bookingCode: 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      userId: 1,
      fieldId: fieldId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      durationHours: durationHours,
      totalPrice: totalPrice,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  // TODO: GET /api/bookings
  static Future<List<Booking>> getMyBookings() async {
    // final res = await ApiService.get('/bookings');
    // return (res['data'] as List).map((e) => Booking.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 800));
    return _dummyBookings;
  }

  // TODO: GET /api/bookings/{id}
  static Future<Booking> getById(int id) async {
    // final res = await ApiService.get('/bookings/$id');
    // return Booking.fromJson(res['data']);

    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyBookings.firstWhere((b) => b.id == id);
  }
}

// ── Dummy data (hapus setelah backend siap) ──────────────────
final List<Booking> _dummyBookings = [];
