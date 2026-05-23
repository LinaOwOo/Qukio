// lib/data/repositories/seed_quiz_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/quiz_model.dart';

class SeedQuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedQuizzes() async {
    final quizzes = [
      QuizModel(
        id: 'quiz_math_001',
        lessonId: 'math_001',
        courseId: 'math',
        questions: [
          QuizQuestion(
            questionText: 'Что такое корень уравнения?',
            options: [
              'Значение переменной, при котором уравнение верно',
              'Коэффициент при x',
              'Свободный член уравнения',
              'Знак уравнения',
            ],
            correctIndex: 0,
          ),
          QuizQuestion(
            questionText: 'Сколько корней имеет уравнение 3x - 6 = 0?',
            options: ['Один', 'Два', 'Бесконечно много', 'Нет корней'],
            correctIndex: 0,
          ),
          QuizQuestion(
            questionText: 'Чему равен x в уравнении 2x = 10?',
            options: ['5', '20', '8', '12'],
            correctIndex: 0,
          ),
        ],
      ),
      QuizModel(
        id: 'quiz_math_002',
        lessonId: 'math_002',
        courseId: 'math',
        questions: [
          QuizQuestion(
            questionText: 'Что такое дискриминант?',
            options: [
              'D = b² - 4ac',
              'D = a + b + c',
              'D = a * b * c',
              'D = a² + b²',
            ],
            correctIndex: 0,
          ),
          QuizQuestion(
            questionText: 'Сколько корней при D > 0?',
            options: ['Два', 'Один', 'Нет корней', 'Бесконечно много'],
            correctIndex: 0,
          ),
          QuizQuestion(
            questionText: 'Формула корней квадратного уравнения:',
            options: [
              'x = (-b ± √D) / 2a',
              'x = -b / 2a',
              'x = b / 2a',
              'x = √D / 2a',
            ],
            correctIndex: 0,
          ),
        ],
      ),
      QuizModel(
        id: 'quiz_physics_001',
        lessonId: 'physics_001',
        courseId: 'physics',
        questions: [
          QuizQuestion(
            questionText: 'Формула пути при равномерном движении:',
            options: ['s = v * t', 's = v / t', 's = t / v', 's = v + t'],
            correctIndex: 0,
          ),
          QuizQuestion(
            questionText: 'Ускорение свободного падения g ≈ ?',
            options: ['9.8 м/с²', '10 м/с', '9.8 км/ч', '100 м/с²'],
            correctIndex: 0,
          ),
          QuizQuestion(
            questionText: 'При равноускоренном движении ускорение:',
            options: ['Постоянно', 'Меняется', 'Равно нулю', 'Отрицательно'],
            correctIndex: 0,
          ),
        ],
      ),
    ];

    for (final quiz in quizzes) {
      await _firestore.collection('quizzes').doc(quiz.id).set(quiz.toMap());
      print('✅ Добавлен квиз: ${quiz.id}');
    }

    print('🎉 Все ${quizzes.length} квизов добавлены!');
  }
}
