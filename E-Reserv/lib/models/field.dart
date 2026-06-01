import '../services/api_service.dart';

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
    String? fullImageUrl = json['foto_lapangan']?.toString().trim();
    if (fullImageUrl != null && fullImageUrl.isNotEmpty) {
      if (fullImageUrl.startsWith('http')) {
        // Already a full URL from backend
      } else {
        final path = fullImageUrl.startsWith('/') ? fullImageUrl.substring(1) : fullImageUrl;
        final normalized =
            path.startsWith('storage/') || path.startsWith('images/')
                ? path
                : 'storage/$path';
        fullImageUrl = '${ApiService.host.replaceAll(RegExp(r'/$'), '')}/$normalized';
      }
    }

    return Field(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? 'Tanpa Nama',
      category: (json['type']?.toString()) ?? 'Lainnya',
      locationType: (json['location_type']?.toString()) ?? 'Indoor',
      pricePerHour: (json['price'] is num) ? (json['price'] as num).toInt() : double.tryParse(json['price']?.toString() ?? '0')?.toInt() ?? 0,
      capacity: (json['capacity'] as int?) ?? 10,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (json['review_count'] as int?) ?? 0,
      isAvailable: json['status'] == 'available' || json['status'] == 1,
      imageUrl: fullImageUrl,
      description: (json['description'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'location_type': locationType,
        'price_per_hour': pricePerHour,
        'capacity': capacity,
        'rating': rating,
        'review_count': reviewCount,
        'is_available': isAvailable,
        'image_url': imageUrl,
        'description': description,
      };
}
