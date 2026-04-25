import 'dart:convert';
import 'package:http/http.dart' as http;

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

void main() async {
  print('Fetching from API...');
  var response = await http.get(Uri.parse('http://localhost:8000/api/fields'));
  print('Status: \${response.statusCode}');
  
  var res = jsonDecode(response.body);
  List data = res is List ? res : res['data'];
  
  print('Data length: \${data.length}');
  
  for (var item in data) {
    try {
      Field f = Field.fromJson(item);
      print('Parsed: \${f.name}');
    } catch (e, st) {
      print("Error parsing item \${item['id']}: \$e");
      print(st);
    }
  }
  print('Done.');
}
