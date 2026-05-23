import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResult {
  final String id;
  final String userId;
  final String quizId;
  final String courseId;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  QuizResult({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.courseId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'courseId': courseId,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': completedAt,
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'] as String,
      userId: map['userId'] as String,
      quizId: map['quizId'] as String,
      courseId: map['courseId'] as String,
      score: map['score'] as int,
      totalQuestions: map['totalQuestions'] as int,
      completedAt: (map['completedAt'] as Timestamp).toDate(),
    );
  }
}
