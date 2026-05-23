import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/quiz_model.dart';

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuizModel?> getQuizByLessonId(String lessonId) async {
    try {
      debugPrint('🔍 Ищем квиз для урока: $lessonId');

      final snapshot = await _firestore
          .collection('quizzes')
          .where('lessonId', isEqualTo: lessonId)
          .limit(1)
          .get();

      debugPrint('📊 Найдено документов: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ Квиз не найден для урока: $lessonId');
        return null;
      }

      final data = snapshot.docs.first.data();
      debugPrint('📋 Данные квиза: $data');

      final quiz = QuizModel.fromMap(data);
      debugPrint('✅ Квиз успешно загружен: ${quiz.id}');
      debugPrint('❓ Количество вопросов: ${quiz.questions.length}');

      return quiz;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка получения квиза: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> saveQuizResult({
    required String userId,
    required String quizId,
    required String lessonId,
    required int score,
    required int totalQuestions,
    required DateTime completedAt,
  }) async {
    try {
      debugPrint('💾 Сохраняем результат квиза...');
      debugPrint('👤 userId: $userId');
      debugPrint('📝 quizId: $quizId');
      debugPrint('📚 lessonId: $lessonId');
      debugPrint('🏆 score: $score / $totalQuestions');

      final percentage = (score / totalQuestions * 100).round();
      debugPrint('📊 percentage: $percentage%');

      await _firestore.collection('quizResults').add({
        'userId': userId,
        'quizId': quizId,
        'lessonId': lessonId,
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': percentage,
        'completedAt': Timestamp.fromDate(completedAt),
      });

      debugPrint('✅ Результат успешно сохранён!');
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка сохранения результата: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<int?> getBestScore(String userId, String lessonId) async {
    try {
      debugPrint(
        '🏆 Ищем лучший результат для userId: $userId, lessonId: $lessonId',
      );

      final snapshot = await _firestore
          .collection('quizResults')
          .where('userId', isEqualTo: userId)
          .where('lessonId', isEqualTo: lessonId)
          .orderBy('percentage', descending: true)
          .limit(1)
          .get();

      debugPrint('📊 Найдено результатов: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ Результатов не найдено');
        return null;
      }

      final bestScore = snapshot.docs.first['score'] as int?;
      debugPrint('✅ Лучший результат: $bestScore');

      return bestScore;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка получения лучшего результата: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserResults(String userId) async {
    try {
      debugPrint('📋 Получаем все результаты для userId: $userId');

      final snapshot = await _firestore
          .collection('quizResults')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      debugPrint('📊 Найдено результатов: ${snapshot.docs.length}');

      final results = snapshot.docs
          .map(
            (doc) => {
              'quizId': doc['quizId'],
              'lessonId': doc['lessonId'],
              'score': doc['score'],
              'totalQuestions': doc['totalQuestions'],
              'percentage': doc['percentage'],
              'completedAt': (doc['completedAt'] as Timestamp).toDate(),
            },
          )
          .toList();

      debugPrint('✅ Результаты успешно получены');
      return results;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка получения результатов: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      return [];
    }
  }

  Future<bool> hasCompletedQuiz(String userId, String lessonId) async {
    try {
      debugPrint(
        '🔍 Проверяем, пройден ли квиз для userId: $userId, lessonId: $lessonId',
      );

      final snapshot = await _firestore
          .collection('quizResults')
          .where('userId', isEqualTo: userId)
          .where('lessonId', isEqualTo: lessonId)
          .limit(1)
          .get();

      final completed = snapshot.docs.isNotEmpty;
      debugPrint('✅ Квиз пройден: $completed');

      return completed;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка проверки статуса квиза: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      return false;
    }
  }
}
