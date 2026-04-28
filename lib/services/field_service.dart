// ============================================================
// field_service.dart
// TODO (backend): sambungkan ke endpoint Laravel
// ============================================================

import '../models/field.dart';
import '../models/schedule.dart';
import 'api_service.dart';

class FieldService {
  // TODO: GET /api/fields
  static Future<List<Field>> getAll() async {
    // Dummy data - ganti dengan:
    // final res = await ApiService.get('/fields');
    // return (res['data'] as List).map((e) => Field.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 800));
    return _dummyFields;
  }

  // TODO: GET /api/fields/{id}
  static Future<Field> getById(int id) async {
    // final res = await ApiService.get('/fields/$id');
    // return Field.fromJson(res['data']);

    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyFields.firstWhere((f) => f.id == id);
  }

  // TODO: GET /api/fields/{id}/schedules
  static Future<List<Schedule>> getSchedules(int fieldId) async {
    // final res = await ApiService.get('/fields/$fieldId/schedules');
    // return (res['data'] as List).map((e) => Schedule.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 500));
    return _dummySchedules.where((s) => s.fieldId == fieldId).toList();
  }
}

// ── Dummy data (hapus setelah backend siap) ──────────────────
final List<Field> _dummyFields = [
  Field(id: 1, name: 'Lapangan Futsal A', category: 'Futsal', locationType: 'Indoor',
      pricePerHour: 80000, rating: 4.9, reviewCount: 128, isAvailable: true,
      description: 'Lapangan futsal standar dengan rumput sintetis berkualitas tinggi.'),
  Field(id: 2, name: 'Lapangan Badminton 1', category: 'Badminton', locationType: 'Indoor',
      pricePerHour: 45000, rating: 4.8, reviewCount: 96, isAvailable: true,
      description: 'Lapangan badminton dengan lantai kayu dan pencahayaan optimal.'),
  Field(id: 3, name: 'Lapangan Basket Outdoor', category: 'Basket', locationType: 'Outdoor',
      pricePerHour: 120000, rating: 4.7, reviewCount: 74, isAvailable: false,
      description: 'Lapangan basket outdoor dengan ring standar internasional.'),
  Field(id: 4, name: 'Lapangan Voli Indoor', category: 'Voli', locationType: 'Indoor',
      pricePerHour: 95000, rating: 4.6, reviewCount: 52, isAvailable: true,
      description: 'Lapangan voli indoor dengan net standar dan lantai anti-slip.'),
  Field(id: 5, name: 'Meja Tenis', category: 'Tenis Meja', locationType: 'Indoor',
      pricePerHour: 30000, rating: 4.5, reviewCount: 41, isAvailable: true,
      description: 'Meja tenis berkualitas dengan bet dan bola tersedia.'),
  Field(id: 6, name: 'Lapangan Tenis', category: 'Tenis', locationType: 'Outdoor',
      pricePerHour: 150000, rating: 4.9, reviewCount: 83, isAvailable: true,
      description: 'Lapangan tenis outdoor dengan permukaan hard court premium.'),
];

final List<Schedule> _dummySchedules = [
  Schedule(id: 1, fieldId: 1, dayOfWeek: 'senin', openTime: '08:00', closeTime: '22:00', isOpen: true),
  Schedule(id: 2, fieldId: 1, dayOfWeek: 'selasa', openTime: '08:00', closeTime: '22:00', isOpen: true),
  Schedule(id: 3, fieldId: 1, dayOfWeek: 'minggu', openTime: '08:00', closeTime: '20:00', isOpen: true),
  Schedule(id: 4, fieldId: 2, dayOfWeek: 'senin', openTime: '07:00', closeTime: '21:00', isOpen: true),
  Schedule(id: 5, fieldId: 2, dayOfWeek: 'sabtu', openTime: '07:00', closeTime: '21:00', isOpen: true),
];
