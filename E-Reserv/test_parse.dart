import 'dart:convert';
class Field {
  final int id;
  final String name;
  final String category;
  final String locationType;
  final int pricePerHour;
  final int capacity;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final String? imageUrl;
  final String description;

  Field({
    required this.id,
    required this.name,
    required this.category,
    required this.locationType,
    required this.pricePerHour,
    required this.capacity,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    this.imageUrl,
    required this.description,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    String? fullImageUrl = json['foto_lapangan'];
    if (fullImageUrl != null && !fullImageUrl.startsWith('http')) {
      fullImageUrl = 'http://localhost:8000/storage/$fullImageUrl';
    }

    return Field(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tanpa Nama',
      category: json['type']?.toString() ?? 'Lainnya',
      locationType: json['location_type']?.toString() ?? 'Indoor',
      pricePerHour: (json['price'] is num) ? (json['price'] as num).toInt() : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      capacity: json['capacity'] ?? 10,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: json['review_count'] ?? 0,
      isAvailable: json['status'] == 'available' || json['status'] == 1,
      imageUrl: fullImageUrl,
      description: json['description'] ?? '',
    );
  }
}

void main() {
  String jsonStr = '''
[{"id":1,"name":"Lapangan Futsal International","type":"Futsal","location_type":"Indoor","price":"150000.00","capacity":10,"foto_lapangan":"images/futsal_international.jpg","status":"available","description":"Lapangan futsal dengan standar internasional dan rumput sintetis berkualitas tinggi.","created_at":"2026-04-25T06:00:50.000000Z","updated_at":"2026-04-25T06:00:50.000000Z"},{"id":2,"name":"Lapangan Futsal Standard","type":"Futsal","location_type":"Indoor","price":"100000.00","capacity":10,"foto_lapangan":"images/futsal_standard.jpg","status":"available","description":null,"created_at":"2026-04-25T06:00:50.000000Z","updated_at":"2026-04-25T06:00:50.000000Z"}]
''';
  List<dynamic> jsonList = jsonDecode(jsonStr);
  for (var item in jsonList) {
    try {
      Field f = Field.fromJson(item);
      print(f.name);
    } catch (e) {
      print('Error on ${item["id"]}: $e');
    }
  }
}
