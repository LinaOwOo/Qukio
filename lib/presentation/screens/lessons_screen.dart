import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // 🔥 Добавь этот импорт

import '../../domain/models/lesson_model.dart';
import '../../core/services/theme_service.dart'; // 🔥 И этот импорт
import 'lesson_screen.dart';

class LessonsListScreen extends StatefulWidget {
  const LessonsListScreen({super.key});
  @override
  State<LessonsListScreen> createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends State<LessonsListScreen> {
  String _filter = 'all';

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
    // 🔥 Получаем тему через ThemeService
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Уроки'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('Все', 'all', isDark),
                  const SizedBox(width: 8),
                  _chip('В процессе', 'in_progress', isDark),
                  const SizedBox(width: 8),
                  _chip('Завершено', 'completed', isDark),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('lessons')
                  .orderBy('order')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: isDark ? Colors.white70 : Colors.blue,
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Уроков пока нет',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  );
                }

                final allLessons = snapshot.data!.docs
                    .map((d) => LessonModel.fromMap(d.data()))
                    .toList();

                // 🔥 БЕЗОПАСНАЯ ФИЛЬТРАЦИЯ
                final lessons = allLessons.where((l) {
                  final done = l.isCompleted ?? false;
                  final prog = l.progress ?? 0;
                  if (_filter == 'all') return true;
                  if (_filter == 'completed') return done;
                  if (_filter == 'in_progress') return !done && prog > 0;
                  return true;
                }).toList();

                if (lessons.isEmpty) {
                  return Center(
                    child: Text(
                      'Нет уроков в этой категории',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    final done = lesson.isCompleted ?? false;
                    final prog = lesson.progress ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      // 🔥 Адаптивный фон карточки
                      color: isDark ? const Color(0xFF2D2D44) : Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDark
                              ? const Color(0xFF667eea).withOpacity(0.3)
                              : Colors.blue.shade100,
                          child: Text(
                            '${lesson.order}',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.blue,
                            ),
                          ),
                        ),
                        title: Text(
                          lesson.title,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getSubjectName(lesson.courseId),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white60
                                    : Colors.grey[600],
                              ),
                            ),
                            if (prog > 0 && !done) ...[
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: prog / 100,
                                backgroundColor: isDark
                                    ? Colors.white24
                                    : Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF667eea),
                                ),
                                minHeight: 4,
                              ),
                              Text(
                                '$prog%',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: done
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : Icon(
                                Icons.arrow_forward_ios,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey[400],
                                size: 16,
                              ),
                        onTap: () {
                          final userId =
                              FirebaseAuth.instance.currentUser?.uid ?? 'guest';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LessonScreen(lesson: lesson, userId: userId),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Добавили параметр isDark
  Widget _chip(String label, String value, bool isDark) {
    final isActive = _filter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isActive
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black87),
          fontSize: 13,
        ),
      ),
      selected: isActive,
      onSelected: (_) => setState(() => _filter = value),
      backgroundColor: isDark ? const Color(0xFF2D2D44) : Colors.grey[200],
      selectedColor: const Color(0xFF667eea),
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isActive
              ? const Color(0xFF667eea)
              : (isDark ? Colors.white24 : Colors.grey[400]!),
        ),
      ),
    );
  }
}
