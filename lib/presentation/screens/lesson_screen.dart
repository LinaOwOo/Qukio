import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🔥 Добавь этот импорт
import 'package:uuid/uuid.dart';
import '../../domain/models/lesson_model.dart';
import '../../domain/models/quote_model.dart';
import '../../data/repositories/quote_repository.dart';
import '../../core/services/theme_service.dart'; // 🔥 И этот импорт
import 'quiz_screen.dart';
import '../../data/repositories/quiz_repository.dart';

class LessonScreen extends StatefulWidget {
  final LessonModel lesson;
  final String userId;

  const LessonScreen({super.key, required this.lesson, required this.userId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final QuoteRepository _quoteRepo = QuoteRepository();
  String? _selectedParagraph;
  bool _isSaving = false;

  List<String> get _paragraphs => widget.lesson.content.split('\n');

  Future<void> _saveQuote() async {
    if (_selectedParagraph == null) return;
    setState(() => _isSaving = true);

    try {
      final quote = QuoteModel(
        id: const Uuid().v4(),
        userId: widget.userId,
        lessonId: widget.lesson.id,
        text: _selectedParagraph!,
        createdAt: DateTime.now(),
      );
      await _quoteRepo.saveQuote(quote);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Цитата сохранена!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      setState(() {
        _selectedParagraph = null;
        _isSaving = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Используем ThemeService вместо Theme.of
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDark;

    // 🔥 Отладка в консоль
    debugPrint('🌓 LessonScreen: isDark = $isDark');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: TextStyle(color: Colors.white), // 🔥 Явно белый цвет
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.blue,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._paragraphs.map((p) => _buildParagraph(p, isDark)),
                ],
              ),
            ),
          ),
          if (_selectedParagraph != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D44) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Выбрано: "${_selectedParagraph!.substring(0, _selectedParagraph!.length > 30 ? 30 : _selectedParagraph!.length)}..."',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveQuote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Сохранить'),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'quiz_btn',
        onPressed: () async {
          final quiz = await QuizRepository().getQuizByLessonId(
            widget.lesson.id,
          );
          if (quiz != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    QuizScreen(quiz: quiz, userId: widget.userId),
              ),
            );
          } else {
            if (mounted)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Квиз пока недоступен')),
              );
          }
        },
        backgroundColor: Colors.purple,
        tooltip: 'Пройти квиз',
        child: const Icon(Icons.quiz),
      ),
    );
  }

  Widget _buildParagraph(String text, bool isDark) {
    final isSelected = _selectedParagraph == text;

    // 🔥 Определяем цвет текста ЯВНО
    final textColor = isSelected
        ? (isDark ? Colors.white : const Color(0xFF1A1A2E))
        : (isDark ? Colors.white70 : const Color(0xFF2C2C2C));

    debugPrint(
      '📝 Paragraph: isDark=$isDark, isSelected=$isSelected, color=$textColor',
    );

    return GestureDetector(
      onTap: () =>
          setState(() => _selectedParagraph = isSelected ? null : text),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.amber.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.amber, width: 2) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: textColor, // 🔥 Используем явно определённый цвет
          ),
        ),
      ),
    );
  }
}
