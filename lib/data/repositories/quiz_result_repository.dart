import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/quiz_result_model.dart';

class QuizResultRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveResult(QuizResult result) async {
    await _db.collection('quizResults').add(result.toMap());
  }

  Stream<List<QuizResult>> getUserResults(String userId) {
    return _db
        .collection('quizResults')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => QuizResult.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<int?> getBestScore(String userId, String quizId) async {
    final snapshot = await _db
        .collection('quizResults')
        .where('userId', isEqualTo: userId)
        .where('quizId', isEqualTo: quizId)
        .orderBy('score', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['score'] as int;
    }
    return null;
  }
}
