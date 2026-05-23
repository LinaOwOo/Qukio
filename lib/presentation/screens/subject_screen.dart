import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/lesson_model.dart';
import 'lesson_screen.dart'; // 🔥 Импорт экрана одного урока

class SubjectScreen extends StatelessWidget {
  final String courseId;
  final List<LessonModel> lessons;

  const SubjectScreen({
    super.key,
    required this.courseId,
    required this.lessons,
  });

  String _getSubjectName(String id) {
    switch (id) {
      case 'math':
        return 'Математика';
      case 'physics':
        return 'Физика';
      case 'chemistry':
        return 'Химия';
      case 'english':
        return 'Английский';
      case 'russian':
        return 'Русский язык';
      case 'history':
        return 'История';
      case 'informatics':
        return 'Информатика';
      default:
        return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    return Scaffold(
      appBar: AppBar(title: Text(_getSubjectName(courseId))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(lesson.title),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonScreen(lesson: lesson, userId: userId),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
