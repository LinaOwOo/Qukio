class QuizQuestion {
  final String questionText;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctIndex': correctIndex,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    // 🔧 Исправление: обрабатываем correctIndex как String или int
    int correctIndex;
    if (map['correctIndex'] is String) {
      correctIndex = int.tryParse(map['correctIndex']) ?? 0;
    } else if (map['correctIndex'] is int) {
      correctIndex = map['correctIndex'];
    } else {
      correctIndex = 0;
    }

    // 🔧 Исправление: обрабатываем options как List
    List<String> options = [];
    if (map['options'] is List) {
      options = (map['options'] as List)
          .map((e) => e?.toString() ?? '')
          .toList();
    }

    return QuizQuestion(
      questionText: map['questionText']?.toString() ?? '',
      options: options,
      correctIndex: correctIndex,
    );
  }
}

class QuizModel {
  final String id;
  final String lessonId;
  final String courseId;
  final List<QuizQuestion> questions;

  const QuizModel({
    required this.id,
    required this.lessonId,
    required this.courseId,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lessonId': lessonId,
      'courseId': courseId,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    // 🔧 Исправление: обрабатываем questions как List
    List<QuizQuestion> questions = [];
    if (map['questions'] is List) {
      questions = (map['questions'] as List)
          .where((q) => q is Map<String, dynamic>)
          .map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
          .toList();
    }

    return QuizModel(
      id: map['id']?.toString() ?? '',
      lessonId: map['lessonId']?.toString() ?? '',
      courseId: map['courseId']?.toString() ?? '',
      questions: questions,
    );
  }
}
