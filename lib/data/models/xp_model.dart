class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String conditionType; // 🔥 ДОБАВЛЕНО
  final dynamic conditionValue; // 🔥 ДОБАВЛЕНО
  final int points;
  final bool isSecret;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.conditionType, // 🔥 ДОБАВЛЕНО
    required this.conditionValue, // 🔥 ДОБАВЛЕНО
    required this.points,
    this.isSecret = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'conditionType': conditionType,
      'conditionValue': conditionValue,
      'points': points,
      'isSecret': isSecret,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String,
      conditionType: map['conditionType'] as String,
      conditionValue: map['conditionValue'],
      points: map['points'] as int,
      isSecret: map['isSecret'] as bool? ?? false,
    );
  }
}
