import 'api_service.dart';
import '../models/models.dart';

class PaymentService {
  // Get Midtrans Snap Token
  static Future<String> getSnapToken(int bookingId, int amount) async {
    final res = await ApiService.post('/payments/snap-token', {
      'booking_id': bookingId,
      'amount': amount,
    });
    // Menyesuaikan dengan response Laravel Midtrans Snap
    return res['snap_token'] ?? '';
  }

  // Create Payment (Manual or Midtrans)
  static Future<Payment> create({
    required int bookingId,
    required int amount,
    required PaymentMethod method,
  }) async {
    final res = await ApiService.post('/payments', {
      'booking_id': bookingId,
      'amount': amount,
      'method': method == PaymentMethod.midtrans ? 'midtrans' : 'manual_transfer',
    });
    return Payment.fromJson(res['data'] ?? res);
  }

  // Upload Proof of Payment (Manual Transfer)
  static Future<void> uploadProof(int paymentId, String filePath) async {
    // Implementasi upload file menggunakan multipart request jika diperlukan
    // Untuk sekarang simulasi atau sesuaikan dengan endpoint Laravel
    await ApiService.post('/payments/$paymentId/upload-proof', {
      'proof': filePath, // Biasanya pakai MultipartFile
    });
  }
}
