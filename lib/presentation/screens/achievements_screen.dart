import 'package:flutter/material.dart';
import '../../domain/models/achievement_model.dart';
import '../../domain/models/user_achievement_model.dart';
import '../../data/repositories/achievement_repository.dart';

class AchievementsScreen extends StatefulWidget {
  final String userId;

  const AchievementsScreen({super.key, required this.userId});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementRepository _repo = AchievementRepository();
  List<Achievement> _all = [];
  List<UserAchievement> _earned = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final all = await _repo.getAllAchievements();
    final earned = await _repo.getUserAchievements(widget.userId);

    setState(() {
      _all = all;
      _earned = earned;
      _loading = false;
    });
  }

  bool _isEarned(String achievementId) {
    return _earned.any((e) => e.achievementId == achievementId);
  }

  IconData _getIcon(String iconName) {
    // 🔁 Простой маппинг строк в иконки
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'trophy':
        return Icons.emoji_events;
      case 'fire':
        return Icons.local_fire_department;
      case 'target':
        return Icons.emoji_events;
      default:
        return Icons.celebration;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Достижения')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _all.length,
        itemBuilder: (context, index) {
          final achievement = _all[index];
          final earned = _isEarned(achievement.id);

          // 🔒 Скрытые достижения не показываем, пока не получены
          if (achievement.isSecret && !earned) {
            return const SizedBox.shrink();
          }

          return Card(
            child: ListTile(
              leading: Icon(
                _getIcon(achievement.icon),
                color: earned ? Colors.amber : Colors.grey,
                size: 32,
              ),
              title: Text(
                achievement.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: earned ? null : Colors.grey,
                ),
              ),
              subtitle: Text(
                earned
                    ? '${achievement.description}\n+${achievement.points} очков'
                    : '???', // скрытое описание
              ),
              trailing: earned
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.lock, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
