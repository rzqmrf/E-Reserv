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
    // Handle image path dari Laravel (menambahkan prefix /storage/)
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
