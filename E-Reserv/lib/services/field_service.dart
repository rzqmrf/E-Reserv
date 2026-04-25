// ============================================================
// field_service.dart
// TODO (backend): sambungkan ke endpoint Laravel
// ============================================================

import '../models/field.dart';
import '../models/schedule.dart';
import 'api_service.dart';

class FieldService {
  // GET /api/fields
  static Future<List<Field>> getAll() async {
    final res = await ApiService.get('/fields');
    // Laravel biasanya membungkus data dalam key 'data'
    final List data = res is List ? res : res['data'];
    return data.map((e) => Field.fromJson(e)).toList();
  }

  // GET /api/fields/{id}
  static Future<Field> getById(int id) async {
    final res = await ApiService.get('/fields/$id');
    return Field.fromJson(res['data'] ?? res);
  }

  // GET /api/fields/{id}/schedules
  static Future<List<Schedule>> getSchedules(int fieldId) async {
    final res = await ApiService.get('/fields/$fieldId/schedules');
    final List data = res is List ? res : res['data'];
    return data.map((e) => Schedule.fromJson(e)).toList();
  }
}

// ── Dummy data (hapus setelah backend siap) ──────────────────

final List<Schedule> _dummySchedules = [
  Schedule(
      id: 1,
      fieldId: 1,
      dayOfWeek: 'senin',
      openTime: '08:00',
      closeTime: '22:00',
      isOpen: true),
  Schedule(
      id: 2,
      fieldId: 1,
      dayOfWeek: 'selasa',
      openTime: '08:00',
      closeTime: '22:00',
      isOpen: true),
  Schedule(
      id: 3,
      fieldId: 1,
      dayOfWeek: 'minggu',
      openTime: '08:00',
      closeTime: '20:00',
      isOpen: true),
  Schedule(
      id: 4,
      fieldId: 2,
      dayOfWeek: 'senin',
      openTime: '07:00',
      closeTime: '21:00',
      isOpen: true),
  Schedule(
      id: 5,
      fieldId: 2,
      dayOfWeek: 'sabtu',
      openTime: '07:00',
      closeTime: '21:00',
      isOpen: true),
];
