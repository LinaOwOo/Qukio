import 'package:cloud_firestore/cloud_firestore.dart';

class XPRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 💰 Начислить опыт
  Future<void> addXP({
    required String userId,
    required int amount,
    required String source,
    String? sourceId,
  }) async {
    await _db.collection('xp').add({
      'userId': userId,
      'amount': amount,
      'source': source,
      'sourceId': sourceId,
      'earnedAt': DateTime.now().toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 📊 Получить общий опыт пользователя
  Future<int> getTotalXP(String userId) async {
    final snapshot = await _db
        .collection('xp')
        .where('userId', isEqualTo: userId)
        .get();

    int total = 0;
    for (final doc in snapshot.docs) {
      final amount = doc['amount'] as int? ?? 0;
      total += amount;
    }
    return total;
  }

  // 🏆 Получить уровень (1 уровень = 100 XP)
  Future<int> getLevel(String userId) async {
    final total = await getTotalXP(userId);
    return (total / 100).floor() + 1;
  }
}
