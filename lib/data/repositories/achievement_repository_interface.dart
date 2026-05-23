import 'package:qukio/domain/models/achievement_model.dart';
import 'package:qukio/domain/models/user_achievement_model.dart';

abstract class AchievementRepositoryInterface {
  // Получить все доступные достижения
  Future<List<Achievement>> getAllAchievements();

  // Получить достижения пользователя
  Future<List<UserAchievement>> getUserAchievements(String userId);

  // Выдать достижение пользователю
  Future<void> awardAchievement(String userId, String achievementId);

  // Проверить и выдать достижения по условию
  Future<void> checkAndAward(
    String userId,
    String eventType,
    dynamic eventData,
  );
}
