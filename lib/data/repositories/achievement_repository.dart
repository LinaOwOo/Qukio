import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/achievement_model.dart';
import '../../domain/models/user_achievement_model.dart';

class AchievementRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Achievement>> getAllAchievements() async {
    final snapshot = await _db.collection('achievements').get();
    return snapshot.docs.map((doc) => Achievement.fromMap(doc.data())).toList();
  }

  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    final snapshot = await _db
        .collection('userAchievements')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      // 🔧 Создаём НОВУЮ изменяемую карту, копируя данные
      final data = Map<String, dynamic>.from(doc.data());
      // 🔧 Добавляем id документа
      data['id'] = doc.id;
      return UserAchievement.fromMap(data);
    }).toList();
  }

  Future<void> awardAchievement(String userId, String achievementId) async {
    final exists = await _db
        .collection('userAchievements')
        .where('userId', isEqualTo: userId)
        .where('achievementId', isEqualTo: achievementId)
        .limit(1)
        .get();

    if (exists.docs.isEmpty) {
      await _db.collection('userAchievements').add({
        'userId': userId,
        'achievementId': achievementId,
        'earnedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> checkAndAward(
    String userId,
    String eventType,
    dynamic eventData,
  ) async {
    final allAchievements = await getAllAchievements();
    final earned = await getUserAchievements(userId);
    final earnedIds = earned.map((e) => e.achievementId).toSet();

    for (final achievement in allAchievements) {
      if (achievement.conditionType != eventType ||
          earnedIds.contains(achievement.id)) {
        continue;
      }

      bool isConditionMet = false;

      if (eventType == 'quiz_completed') {
        final score = eventData['score'] as int;
        final total = eventData['total'] as int;
        final percentage = total > 0 ? (score / total * 100).round() : 0;

        if (achievement.id == 'perfect_quiz' && percentage == 100) {
          isConditionMet = true;
        } else if (achievement.id == 'first_step') {
          isConditionMet = true;
        }
      }

      if (eventType == 'xp_earned') {
        final totalXP = eventData['totalXP'] as int;
        if (totalXP >= achievement.conditionValue) {
          isConditionMet = true;
        }
      }

      if (isConditionMet) {
        await awardAchievement(userId, achievement.id);
        debugPrint('🏆 Выдано достижение: ${achievement.title}');
      }
    }
  }
}
