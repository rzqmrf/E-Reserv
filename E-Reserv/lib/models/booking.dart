import 'field.dart';
import 'user.dart';

enum BookingStatus { pending, approved, rejected }

class Booking {
  final int id;
  final String bookingCode;
  final int userId;
  final int fieldId;
  final DateTime date;
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final int durationHours;
  final int totalPrice;
  final int personCount;
  final BookingStatus status;
  final DateTime createdAt;

  // relasi (optional, dari API dengan eager loading)
  final User? user;
  final Field? field;

  Booking({
    required this.id,
    required this.bookingCode,
    required this.userId,
    required this.fieldId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalPrice,
    required this.personCount,
    required this.status,
    required this.createdAt,
    this.user,
    this.field,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: (json['id'] as int?) ?? 0,
        bookingCode: (json['booking_code'] as String?) ?? '',
        userId: (json['user_id'] as int?) ?? 0,
        fieldId: (json['field_id'] as int?) ?? 0,
        date: json['date'] != null
            ? DateTime.parse(json['date'])
            : DateTime.now(),
        startTime: (json['start_time'] as String?) ?? '00:00',
        endTime: (json['end_time'] as String?) ?? '00:00',
        durationHours: (json['duration_hours'] as int?) ?? 1,
        totalPrice: (json['total_price'] is num)
            ? (json['total_price'] as num).toInt()
            : double.tryParse(json['total_price']?.toString() ?? '0')
                    ?.toInt() ??
                0,
        personCount: int.tryParse(json['person_count']?.toString() ?? '1') ?? 1,

        status: _parseStatus(json['status'] as String?),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        field: json['field'] != null ? Field.fromJson(json['field']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_code': bookingCode,
        'user_id': userId,
        'field_id': fieldId,
        'date': date.toIso8601String().split('T').first,
        'start_time': startTime,
        'end_time': endTime,
        'duration_hours': durationHours,
        'total_price': totalPrice,
        'person_count': personCount,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
      };

  static BookingStatus _parseStatus(String? s) {
    switch (s) {
      case 'approved':
        return BookingStatus.approved;
      case 'rejected':
        return BookingStatus.rejected;
      default:
        return BookingStatus.pending;
    }
  }

  // Helper format tanggal tanpa intl
  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
