import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart'; // 🔥 Добавь этот импорт

import '../../domain/models/quiz_model.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../data/repositories/xp_repository.dart';
import '../../core/services/theme_service.dart'; // 🔥 И этот импорт

class QuizScreen extends StatefulWidget {
  final QuizModel quiz;
  final String userId;

  const QuizScreen({super.key, required this.quiz, required this.userId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizRepository _quizRepo = QuizRepository();
  final AchievementRepository _achievementRepo = AchievementRepository();
  final XPRepository _xpRepo = XPRepository();

  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerChecked = false;
  bool _isCorrect = false;

  final List<int> _userAnswers = [];
  int _score = 0;
  bool _isCompleted = false;

  QuizQuestion get _currentQuestion =>
      widget.quiz.questions[_currentQuestionIndex];

  void _selectOption(int index) {
    if (_isAnswerChecked) return;
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _checkAnswer() {
    if (_selectedOptionIndex == null) return;

    final isCorrect = _selectedOptionIndex == _currentQuestion.correctIndex;

    setState(() {
      _isAnswerChecked = true;
      _isCorrect = isCorrect;
      if (isCorrect) {
        _score++;
      }
      _userAnswers.add(_selectedOptionIndex!);
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswerChecked = false;
        _isCorrect = false;
      });
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    setState(() {
      _isCompleted = true;
    });

    try {
      await _quizRepo.saveQuizResult(
        userId: widget.userId,
        quizId: widget.quiz.id,
        lessonId: widget.quiz.lessonId,
        score: _score,
        totalQuestions: widget.quiz.questions.length,
        completedAt: DateTime.now(),
      );

      final baseXP = 10;
      final bonusXP = _score * 2;
      final totalXP = baseXP + bonusXP;

      await _xpRepo.addXP(
        userId: widget.userId,
        amount: totalXP,
        source: 'quiz',
        sourceId: widget.quiz.id,
      );
      debugPrint('✅ Начислено $totalXP XP');

      await _achievementRepo.checkAndAward(widget.userId, 'quiz_completed', {
        'score': _score,
        'total': widget.quiz.questions.length,
      });

      final currentTotalXP = await _xpRepo.getTotalXP(widget.userId);
      await _achievementRepo.checkAndAward(widget.userId, 'xp_earned', {
        'totalXP': currentTotalXP,
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('❌ Ошибка: $e');
      if (mounted) {
        Navigator.pop(context, false);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _isAnswerChecked = false;
      _isCorrect = false;
      _userAnswers.clear();
      _score = 0;
      _isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Получаем тему
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDark;

    if (_isCompleted) {
      return _buildResultScreen(isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      appBar: AppBar(
        title: Text(
          'Вопрос ${_currentQuestionIndex + 1} из ${widget.quiz.questions.length}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.blue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
              backgroundColor: isDark ? Colors.white24 : Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              color: isDark ? const Color(0xFF2D2D44) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _currentQuestion.questionText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ..._currentQuestion.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return _buildOptionTile(index, option, isDark);
            }),
            const Spacer(),
            _buildActionButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(int index, String option, bool isDark) {
    Color? tileColor;
    IconData? icon;
    Color? iconColor;

    if (_isAnswerChecked) {
      if (index == _currentQuestion.correctIndex) {
        tileColor = Colors.green.shade100;
        icon = Icons.check_circle;
        iconColor = Colors.green;
      } else if (index == _selectedOptionIndex && !_isCorrect) {
        tileColor = Colors.red.shade100;
        icon = Icons.error;
        iconColor = Colors.red;
      }
    } else if (_selectedOptionIndex == index) {
      tileColor = isDark
          ? const Color(0xFF667eea).withOpacity(0.3)
          : Colors.blue.shade100;
    }

    return Card(
      color: tileColor ?? (isDark ? const Color(0xFF2D2D44) : Colors.white),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _selectedOptionIndex == index
              ? Colors.blue
              : (isDark ? Colors.white24 : Colors.grey[300]),
          child: Text(
            String.fromCharCode(65 + index),
            style: TextStyle(
              color: _selectedOptionIndex == index
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ),
        title: Text(
          option,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        trailing: icon != null ? Icon(icon, color: iconColor) : null,
        onTap: () => _selectOption(index),
      ),
    );
  }

  Widget _buildActionButton(bool isDark) {
    if (!_isAnswerChecked) {
      return ElevatedButton(
        onPressed: _selectedOptionIndex != null ? _checkAnswer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Проверить', style: TextStyle(fontSize: 16)),
      );
    }

    return ElevatedButton(
      onPressed: _nextQuestion,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        _currentQuestionIndex < widget.quiz.questions.length - 1
            ? 'Следующий вопрос'
            : 'Завершить квиз',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildResultScreen(bool isDark) {
    final percentage = (_score / widget.quiz.questions.length * 100).round();
    final isPassed = percentage >= 70;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      appBar: AppBar(
        title: const Text('Результат'),
        backgroundColor: isDark
            ? const Color(0xFF1A1A2E)
            : (isPassed ? Colors.green : Colors.orange),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(
                  isPassed ? Icons.emoji_events : Icons.sentiment_neutral,
                  size: 100,
                  color: isPassed ? Colors.amber : Colors.orange,
                ),
                const SizedBox(height: 24),
                Text(
                  isPassed ? 'Поздравляем!' : 'Попробуй ещё раз',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ваш результат: $_score из ${widget.quiz.questions.length}',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 32),
                if (!isPassed)
                  ElevatedButton(
                    onPressed: _restartQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Попробовать снова',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () {
                    final courseName = widget.quiz.lessonId;
                    Share.share(
                      '🏆 Я набрал $percentage% в квизе "$courseName"!\nПопробуй и ты в приложении Qurio!',
                      subject: 'Мой результат в Qurio',
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Поделиться'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    side: BorderSide(
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                  child: Text(
                    'Вернуться к уроку',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
