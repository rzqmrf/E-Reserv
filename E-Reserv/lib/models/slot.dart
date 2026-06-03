class Slot {
  final int id;
  final int fieldId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int capacity;       // kapasitas maksimal
  final int bookedCount;    // sudah berapa yang booking
  final bool isAvailable;
  final String? hostName;
  final String? hostPhone;

  Slot({
    required this.id,
    required this.fieldId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.bookedCount,
    required this.isAvailable,
    this.hostName,
    this.hostPhone,
  });

  int get remainingCapacity => capacity - bookedCount;
  bool get isFull => remainingCapacity <= 0;

  factory Slot.fromJson(Map<String, dynamic> j) => Slot(
        id: j['id'],
        fieldId: j['field_id'],
        date: DateTime.parse(j['date']),
        startTime: j['start_time'],
        endTime: j['end_time'],
        capacity: j['capacity'] ?? 10,
        bookedCount: j['booked_count'] ?? 0,
        isAvailable: j['is_available'] == true || j['is_available'] == 1,
        hostName: j['host_name'],
        hostPhone: j['host_phone'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'field_id': fieldId,
        'date': date.toIso8601String().split('T').first,
        'start_time': startTime,
        'end_time': endTime,
        'capacity': capacity,
        'booked_count': bookedCount,
        'is_available': isAvailable,
        'host_name': hostName,
        'host_phone': hostPhone,
      };
}
