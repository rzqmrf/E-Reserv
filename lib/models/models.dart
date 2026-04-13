import 'package:flutter/material.dart';

// ─── 1. USER ──────────────────────────────────────────────────
class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final DateTime createdAt;

  User({required this.id, required this.name, required this.email,
      required this.phone, this.photoUrl, required this.createdAt});

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'], name: j['name'], email: j['email'], phone: j['phone'] ?? '',
        photoUrl: j['photo_url'], createdAt: DateTime.parse(j['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'email': email, 'phone': phone,
        'photo_url': photoUrl, 'created_at': createdAt.toIso8601String(),
      };

  String get initials => name.trim().split(' ')
      .map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
}

// ─── 2. FIELD ─────────────────────────────────────────────────
class Field {
  final int id;
  final String name;
  final String category;
  final String locationType; // indoor / outdoor
  final int pricePerHour;
  final int capacity;        // kapasitas maksimal orang
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final String? imageUrl;
  final String description;

  Field({required this.id, required this.name, required this.category,
      required this.locationType, required this.pricePerHour,
      required this.capacity, required this.rating, required this.reviewCount,
      required this.isAvailable, this.imageUrl, required this.description});

  factory Field.fromJson(Map<String, dynamic> j) => Field(
        id: j['id'], name: j['name'], category: j['category'],
        locationType: j['location_type'] ?? 'Indoor',
        pricePerHour: j['price_per_hour'] ?? j['price'] ?? 0,
        capacity: j['capacity'] ?? 10,
        rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: j['review_count'] ?? 0,
        isAvailable: j['is_available'] == true || j['is_available'] == 1 ||
            j['status'] == 'available',
        imageUrl: j['image_url'], description: j['description'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'category': category,
        'location_type': locationType, 'price_per_hour': pricePerHour,
        'capacity': capacity, 'rating': rating, 'review_count': reviewCount,
        'is_available': isAvailable, 'image_url': imageUrl, 'description': description,
      };
}

// ─── 3. SCHEDULE ──────────────────────────────────────────────
class Schedule {
  final int id;
  final int fieldId;
  final String dayOfWeek;
  final String openTime;
  final String closeTime;
  final bool isOpen;

  Schedule({required this.id, required this.fieldId, required this.dayOfWeek,
      required this.openTime, required this.closeTime, required this.isOpen});

  factory Schedule.fromJson(Map<String, dynamic> j) => Schedule(
        id: j['id'], fieldId: j['field_id'], dayOfWeek: j['day_of_week'],
        openTime: j['open_time'], closeTime: j['close_time'],
        isOpen: j['is_open'] == true || j['is_open'] == 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'field_id': fieldId, 'day_of_week': dayOfWeek,
        'open_time': openTime, 'close_time': closeTime, 'is_open': isOpen,
      };
}

// ─── 4. SLOT ──────────────────────────────────────────────────
class Slot {
  final int id;
  final int fieldId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int capacity;       // kapasitas maksimal
  final int bookedCount;    // sudah berapa yang booking
  final bool isAvailable;

  Slot({required this.id, required this.fieldId, required this.date,
      required this.startTime, required this.endTime, required this.capacity,
      required this.bookedCount, required this.isAvailable});

  int get remainingCapacity => capacity - bookedCount;
  bool get isFull => remainingCapacity <= 0;

  factory Slot.fromJson(Map<String, dynamic> j) => Slot(
        id: j['id'], fieldId: j['field_id'],
        date: DateTime.parse(j['date']),
        startTime: j['start_time'], endTime: j['end_time'],
        capacity: j['capacity'] ?? 10,
        bookedCount: j['booked_count'] ?? 0,
        isAvailable: j['is_available'] == true || j['is_available'] == 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'field_id': fieldId,
        'date': date.toIso8601String().split('T').first,
        'start_time': startTime, 'end_time': endTime,
        'capacity': capacity, 'booked_count': bookedCount,
        'is_available': isAvailable,
      };
}

// ─── 5. BOOKING ───────────────────────────────────────────────
enum BookingStatus { pending, approved, rejected }

class Booking {
  final int id;
  final String bookingCode;
  final int userId;
  final int fieldId;
  final int slotId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int durationHours;
  final int totalPrice;
  final int personCount;    // jumlah orang yang booking
  final BookingStatus status;
  final DateTime createdAt;
  final User? user;
  final Field? field;
  final Slot? slot;

  Booking({required this.id, required this.bookingCode, required this.userId,
      required this.fieldId, required this.slotId, required this.date,
      required this.startTime, required this.endTime, required this.durationHours,
      required this.totalPrice, required this.personCount, required this.status,
      required this.createdAt, this.user, this.field, this.slot});

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: j['id'], bookingCode: j['booking_code'] ?? '',
        userId: j['user_id'], fieldId: j['field_id'], slotId: j['slot_id'] ?? 0,
        date: DateTime.parse(j['date']),
        startTime: j['start_time'], endTime: j['end_time'],
        durationHours: j['duration_hours'] ?? 1,
        totalPrice: j['total_price'] ?? 0,
        personCount: j['person_count'] ?? 1,
        status: _parseStatus(j['status']),
        createdAt: DateTime.parse(j['created_at']),
        user: j['user'] != null ? User.fromJson(j['user']) : null,
        field: j['field'] != null ? Field.fromJson(j['field']) : null,
        slot: j['slot'] != null ? Slot.fromJson(j['slot']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'booking_code': bookingCode, 'user_id': userId,
        'field_id': fieldId, 'slot_id': slotId,
        'date': date.toIso8601String().split('T').first,
        'start_time': startTime, 'end_time': endTime,
        'duration_hours': durationHours, 'total_price': totalPrice,
        'person_count': personCount, 'status': status.name,
        'created_at': createdAt.toIso8601String(),
      };

  static BookingStatus _parseStatus(String? s) {
    switch (s) {
      case 'approved': return BookingStatus.approved;
      case 'rejected': return BookingStatus.rejected;
      default: return BookingStatus.pending;
    }
  }

  String get formattedDate {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ─── 6. PAYMENT ───────────────────────────────────────────────
enum PaymentStatus { unpaid, paid, failed }

class Payment {
  final int id;
  final int bookingId;
  final int amount;
  final String method;
  final PaymentStatus status;
  final String? snapToken;
  final String? proofUrl;
  final DateTime? paidAt;
  final DateTime createdAt;
  final Booking? booking;

  Payment({required this.id, required this.bookingId, required this.amount,
      required this.method, required this.status, this.snapToken,
      this.proofUrl, this.paidAt, required this.createdAt, this.booking});

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
        id: j['id'], bookingId: j['booking_id'], amount: j['amount'] ?? 0,
        method: j['method'] ?? 'midtrans',
        status: _parseStatus(j['status']),
        snapToken: j['snap_token'], proofUrl: j['proof_url'],
        paidAt: j['paid_at'] != null ? DateTime.parse(j['paid_at']) : null,
        createdAt: DateTime.parse(j['created_at']),
        booking: j['booking'] != null ? Booking.fromJson(j['booking']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'booking_id': bookingId, 'amount': amount,
        'method': method, 'status': status.name,
        'snap_token': snapToken, 'proof_url': proofUrl,
        'paid_at': paidAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  static PaymentStatus _parseStatus(String? s) {
    switch (s) {
      case 'paid': return PaymentStatus.paid;
      case 'failed': return PaymentStatus.failed;
      default: return PaymentStatus.unpaid;
    }
  }
}

// ─── DUMMY DATA ───────────────────────────────────────────────
final List<Field> dummyFields = [
  Field(id:1, name:'Lapangan Futsal A', category:'Futsal', locationType:'Indoor',
      pricePerHour:80000, capacity:10, rating:4.9, reviewCount:128,
      isAvailable:true, description:'Lapangan futsal dengan rumput sintetis berkualitas.'),
  Field(id:2, name:'Lapangan Badminton 1', category:'Badminton', locationType:'Indoor',
      pricePerHour:45000, capacity:4, rating:4.8, reviewCount:96,
      isAvailable:true, description:'Lapangan badminton dengan lantai kayu dan net standar.'),
  Field(id:3, name:'Lapangan Basket Outdoor', category:'Basket', locationType:'Outdoor',
      pricePerHour:120000, capacity:20, rating:4.7, reviewCount:74,
      isAvailable:false, description:'Lapangan basket outdoor dengan ring standar internasional.'),
  Field(id:4, name:'Lapangan Voli Indoor', category:'Voli', locationType:'Indoor',
      pricePerHour:95000, capacity:12, rating:4.6, reviewCount:52,
      isAvailable:true, description:'Lapangan voli indoor dengan net anti-slip.'),
  Field(id:5, name:'Meja Tenis', category:'Tenis Meja', locationType:'Indoor',
      pricePerHour:30000, capacity:4, rating:4.5, reviewCount:41,
      isAvailable:true, description:'Meja tenis berkualitas dengan bet dan bola tersedia.'),
  Field(id:6, name:'Lapangan Tenis', category:'Tenis', locationType:'Outdoor',
      pricePerHour:150000, capacity:4, rating:4.9, reviewCount:83,
      isAvailable:true, description:'Lapangan tenis outdoor dengan hard court premium.'),
];

// Dummy slots untuk field id=1, hari ini
List<Slot> generateDummySlots(int fieldId, DateTime date, int capacity) {
  final slots = <Slot>[];
  final bookedCounts = [0, 2, capacity, 1, 0, 3, capacity, 0, 0, 2];
  int slotId = 1;
  for (int h = 8; h < 22; h++) {
    final booked = bookedCounts[(h - 8) % bookedCounts.length];
    slots.add(Slot(
      id: slotId++, fieldId: fieldId, date: date,
      startTime: '${h.toString().padLeft(2,'0')}:00',
      endTime: '${(h+1).toString().padLeft(2,'0')}:00',
      capacity: capacity, bookedCount: booked,
      isAvailable: booked < capacity,
    ));
  }
  return slots;
}

// Global booking history (in-memory)
List<Booking> bookingHistory = [];
