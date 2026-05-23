// 📁 lib/domain/models/user_achievement_model.dart

class UserAchievement {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime earnedAt;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.earnedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'achievementId': achievementId,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }

  // 🔧 100% безопасный fromMap
  factory UserAchievement.fromMap(Map<String, dynamic> map) {
    return UserAchievement(
      id: map['id']?.toString() ?? 'unknown_id',
      userId: map['userId']?.toString() ?? 'unknown_user',
      achievementId: map['achievementId']?.toString() ?? 'unknown_achievement',
      earnedAt: _safeParseDate(map['earnedAt']),
    );
  }

  // 🔧 Универсальный парсер даты (Timestamp, String, DateTime, null)
  static DateTime _safeParseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();

    // Firestore часто отдаёт объект Timestamp
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }
}
