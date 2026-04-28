// ============================================================
// payment_service.dart
// TODO (backend): sambungkan ke endpoint Laravel
// ============================================================

import '../models/payment.dart';
import 'api_service.dart';

class PaymentService {
  // TODO: POST /api/payments
  static Future<Payment> create({
    required int bookingId,
    required int amount,
    required PaymentMethod method,
    String? proofUrl,
  }) async {
    // Dummy - ganti dengan:
    // final res = await ApiService.post('/payments', {
    //   'booking_id': bookingId,
    //   'amount': amount,
    //   'method': method == PaymentMethod.bankTransfer ? 'bank_transfer' : 'e_wallet',
    //   'proof_url': proofUrl,
    // });
    // return Payment.fromJson(res['data']);

    await Future.delayed(const Duration(seconds: 1));
    return Payment(
      id: DateTime.now().millisecondsSinceEpoch,
      bookingId: bookingId,
      amount: amount,
      method: method,
      status: PaymentStatus.unpaid,
      proofUrl: proofUrl,
      createdAt: DateTime.now(),
    );
  }

  // TODO: GET /api/payments/{id}
  static Future<Payment> getById(int id) async {
    // final res = await ApiService.get('/payments/$id');
    // return Payment.fromJson(res['data']);

    await Future.delayed(const Duration(milliseconds: 500));
    throw Exception('Payment tidak ditemukan');
  }

  // TODO: POST /api/payments/{id}/upload-proof
  // Upload bukti pembayaran ke server
  static Future<String> uploadProof(int paymentId, String filePath) async {
    // Gunakan MultipartRequest untuk upload file
    // final req = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/payments/$paymentId/upload-proof'));
    // req.files.add(await http.MultipartFile.fromPath('proof', filePath));
    // req.headers.addAll(ApiService.headers);
    // final res = await req.send();
    // return resBody['proof_url'];

    await Future.delayed(const Duration(seconds: 1));
    return 'https://dummy-url.com/proof.jpg';
  }
}
