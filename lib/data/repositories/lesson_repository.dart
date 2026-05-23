import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/lesson_model.dart';

class LessonRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<LessonModel>> getAllLessons() async {
    try {
      final snapshot = await _db.collection('lessons').get();
      return snapshot.docs
          .map((doc) => LessonModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('❌ Ошибка получения уроков: $e');
      return [];
    }
  }

  Future<List<LessonModel>> getLessonsByCourse(String courseId) async {
    try {
      final snapshot = await _db
          .collection('lessons')
          .where('courseId', isEqualTo: courseId)
          .get();
      return snapshot.docs
          .map((doc) => LessonModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('❌ Ошибка получения уроков курса: $e');
      return [];
    }
  }

  /// 🔥 НОВЫЙ МЕТОД: Возвращает количество пройденных уроков по курсу
  Future<int> getCompletedLessonsCount(String userId, String courseId) async {
    try {
      // 1. Получаем все уроки этого курса
      final lessonsSnapshot = await _db
          .collection('lessons')
          .where('courseId', isEqualTo: courseId)
          .get();

      // 🔥 ИСПРАВЛЕНО: используем doc.id (документный ID Firestore) как lessonId
      // Если в модели урока есть поле 'id', можно использовать его: d.data()['id'] ?? d.id
      final lessonIds = lessonsSnapshot.docs.map((d) => d.id).toList();

      debugPrint('📚 Курс "$courseId": найдено уроков: ${lessonIds.length}');
      debugPrint('📋 ID уроков: $lessonIds');

      if (lessonIds.isEmpty) return 0;

      // 2. Ищем результаты пользователя по этим урокам
      // (ограничение: whereIn работает максимум с 10 значениями)
      int completedCount = 0;

      for (var i = 0; i < lessonIds.length; i += 10) {
        final batch = lessonIds.sublist(
          i,
          i + 10 > lessonIds.length ? lessonIds.length : i + 10,
        );

        debugPrint('🔍 Поиск результатов для пакета: $batch');

        final resultsSnapshot = await _db
            .collection('quizResults')
            .where('userId', isEqualTo: userId)
            .where('lessonId', whereIn: batch)
            .get();

        debugPrint('✅ Найдено результатов: ${resultsSnapshot.docs.length}');
        completedCount += resultsSnapshot.docs.length;
      }

      debugPrint('📊 Итого пройдено уроков: $completedCount');
      return completedCount;
    } catch (e, stack) {
      debugPrint('❌ Ошибка расчёта прогресса: $e');
      debugPrint('📋 Stack: $stack');
      return 0;
    }
  }

  /// 🔥 НОВЫЙ МЕТОД: Проверка, пройден ли конкретный урок
  Future<bool> isLessonCompleted(String userId, String lessonId) async {
    try {
      final snapshot = await _db
          .collection('quizResults')
          .where('userId', isEqualTo: userId)
          .where('lessonId', isEqualTo: lessonId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Ошибка проверки статуса урока: $e');
      return false;
    }
  }
}
