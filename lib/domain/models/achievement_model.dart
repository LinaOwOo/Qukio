class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String conditionType;
  final dynamic conditionValue;
  final int points;
  final bool isSecret;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.conditionType,
    this.conditionValue,
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
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Без названия',
      description: map['description'] as String? ?? '',
      icon: map['icon'] as String? ?? 'star',
      conditionType: map['conditionType'] as String? ?? '',
      conditionValue: map['conditionValue'],
      points: map['points'] as int? ?? 0,
      isSecret: map['isSecret'] as bool? ?? false,
    );
  }
}
