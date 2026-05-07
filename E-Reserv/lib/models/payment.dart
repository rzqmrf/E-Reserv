import 'booking.dart';

enum PaymentMethod { midtrans, manualTransfer }
enum PaymentStatus { unpaid, paid, failed }

class Payment {
  final int id;
  final int bookingId;
  final int amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? proofUrl;   // URL bukti pembayaran
  final DateTime? paidAt;
  final DateTime createdAt;

  // relasi
  final Booking? booking;

  Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    this.proofUrl,
    this.paidAt,
    required this.createdAt,
    this.booking,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        bookingId: (json['booking_id'] is num) ? (json['booking_id'] as num).toInt() : int.tryParse(json['booking_id']?.toString() ?? '0') ?? 0,
        amount: (json['amount'] is num) ? (json['amount'] as num).toInt() : double.tryParse(json['amount']?.toString() ?? '0')?.toInt() ?? 0,
        method: _parseMethod(json['method']?.toString() ?? ''),
        status: _parseStatus(json['status']?.toString() ?? ''),
        proofUrl: json['proof_url'],
        paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        booking: json['booking'] != null ? Booking.fromJson(json['booking']) : null,
      );


  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_id': bookingId,
        'amount': amount,
        'method': method == PaymentMethod.midtrans ? 'midtrans' : 'manual_transfer',
        'status': status.name,
        'proof_url': proofUrl,
        'paid_at': paidAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  static PaymentMethod _parseMethod(String m) {
    if (m == 'manual_transfer') return PaymentMethod.manualTransfer;
    return PaymentMethod.midtrans;
  }

  static PaymentStatus _parseStatus(String s) {
    switch (s) {
      case 'paid': return PaymentStatus.paid;
      case 'failed': return PaymentStatus.failed;
      default: return PaymentStatus.unpaid;
    }
  }
}

