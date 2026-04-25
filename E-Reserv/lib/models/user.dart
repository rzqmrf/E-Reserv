class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: (json['id'] as int?) ?? 0,
        name: (json['name'] as String?) ?? 'Pengguna',
        email: (json['email'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '-',
        photoUrl: json['photo_url'] as String?,
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at']) 
            : DateTime.now(),
      );
      
  String get initials => name.trim().split(' ')
      .map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'photo_url': photoUrl,
        'created_at': createdAt.toIso8601String(),
      };
}
