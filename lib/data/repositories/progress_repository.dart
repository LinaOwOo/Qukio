import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_progress_model.dart';

class ProgressRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveProgress(UserProgress progress) async {
    await _db.collection('userProgress').add(progress.toMap());
  }

  Stream<List<UserProgress>> getProgress(String userId) {
    return _db
        .collection('userProgress')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserProgress.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<UserProgress?> getLessonProgress(
    String userId,
    String lessonId,
  ) async {
    final snapshot = await _db
        .collection('userProgress')
        .where('userId', isEqualTo: userId)
        .where('lessonId', isEqualTo: lessonId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return UserProgress.fromMap(snapshot.docs.first.data());
    }
    return null;
  }
}
