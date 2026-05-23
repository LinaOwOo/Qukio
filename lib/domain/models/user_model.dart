class UserModel {
  final String id;
  final String name;
  final int rating;
  final String avatarUrl;
  final int level;

  const UserModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.avatarUrl,
    required this.level,
  });

  UserModel copyWith({
    String? id,
    String? name,
    int? rating,
    String? avatarUrl,
    int? level,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'avatarUrl': avatarUrl,
      'level': level,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      rating: map['rating'] ?? 0,
      avatarUrl: map['avatarUrl'] ?? '',
      level: map['level'] ?? 1,
    );
  }
}
