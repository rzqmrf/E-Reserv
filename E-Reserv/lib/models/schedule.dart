class Schedule {
  final int id;
  final int fieldId;
  final String dayOfWeek; // senin, selasa, rabu, kamis, jumat, sabtu, minggu
  final String openTime;  // format HH:mm, contoh "08:00"
  final String closeTime; // format HH:mm, contoh "22:00"
  final bool isOpen;

  Schedule({
    required this.id,
    required this.fieldId,
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        id: (json['id'] as int?) ?? 0,
        fieldId: (json['field_id'] as int?) ?? 0,
        dayOfWeek: (json['day_of_week'] as String?) ?? '',
        openTime: (json['open_time'] as String?) ?? '08:00',
        closeTime: (json['close_time'] as String?) ?? '22:00',
        isOpen: json['is_open'] == true || json['is_open'] == 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'field_id': fieldId,
        'day_of_week': dayOfWeek,
        'open_time': openTime,
        'close_time': closeTime,
        'is_open': isOpen,
      };
}
