import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final String userId;
  final String lessonId;
  final bool isCompleted;
  final int score;
  final DateTime completedAt;

  UserProgress({
    required this.userId,
    required this.lessonId,
    required this.isCompleted,
    required this.score,
    required this.completedAt,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'] as String,
      lessonId: map['lessonId'] as String,
      isCompleted: map['isCompleted'] as bool,
      score: map['score'] as int,
      completedAt: (map['completedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      'isCompleted': isCompleted,
      'score': score,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}
