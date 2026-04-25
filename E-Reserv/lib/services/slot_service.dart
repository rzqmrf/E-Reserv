import '../models/models.dart';
import 'api_service.dart';

class SlotService {
  // GET /api/fields/{fieldId}/slots?date=YYYY-MM-DD
  static Future<List<Slot>> getByFieldAndDate(int fieldId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;
    final res = await ApiService.get('/fields/$fieldId/slots?date=$dateStr');
    final List data = res is List ? res : (res['data'] ?? []);
    return data.map((e) => Slot.fromJson(e)).toList();
  }
}
