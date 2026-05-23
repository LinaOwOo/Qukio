import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🔥 Добавь этот импорт
import '../../data/repositories/lesson_repository.dart';
import '../../domain/models/lesson_model.dart';
import 'subject_screen.dart';
import 'achievements_screen.dart';
import '../../core/services/theme_service.dart'; // 🔥 И сервис тем
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LessonRepository _repo = LessonRepository();
  final TextEditingController _searchController = TextEditingController();
  Map<String, List<LessonModel>> _grouped = {};
  Map<String, int> _progress = {};
  bool _loading = true;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadData() async {
    try {
      debugPrint('🔄 Начинаю загрузку уроков...');
      final lessons = await _repo.getAllLessons();
      debugPrint('✅ Уроков загружено: ${lessons.length}');

      final grouped = <String, List<LessonModel>>{};
      final progress = <String, int>{};

      for (final lesson in lessons) {
        grouped.putIfAbsent(lesson.courseId, () => []).add(lesson);
        progress[lesson.courseId] = lesson.progress ?? 0;
      }

      if (mounted) {
        setState(() {
          _grouped = grouped;
          _progress = progress;
          _loading = false;
        });
        debugPrint('✅ UI обновлён');
      }
    } catch (e, stack) {
      debugPrint('❌ Ошибка в _loadData: $e');
      debugPrint('📋 Стек: $stack');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось загрузить: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

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

  IconData _getSubjectIcon(String id) {
    switch (id) {
      case 'math':
        return Icons.calculate;
      case 'physics':
        return Icons.science;
      case 'chemistry':
        return Icons.biotech;
      case 'english':
        return Icons.language;
      case 'russian':
        return Icons.menu_book;
      case 'history':
        return Icons.history;
      case 'informatics':
        return Icons.computer;
      default:
        return Icons.book;
    }
  }

  Color _getSubjectBgColor(String id) {
    switch (id) {
      case 'math':
        return const Color(0xFF9891F8);
      case 'physics':
        return const Color(0xFFD4C1EC);
      case 'chemistry':
        return const Color(0xFFFB6EE1);
      case 'english':
        return const Color(0xFF00FF5E);
      case 'russian':
        return const Color(0xFFE31F39);
      case 'history':
        return const Color(0xFFFF8800);
      case 'informatics':
        return const Color(0xFF001F97);
      default:
        return const Color(0xFFE0E7F0);
    }
  }

  Widget _buildSubjectImage(String courseId) {
    return Image.asset(
      'assets/images/${courseId}_icon.jpg',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(courseId);
      },
    );
  }

  Widget _buildPlaceholder(String courseId) {
    return Center(
      child: Icon(
        _getSubjectIcon(courseId),
        size: 120,
        color: Colors.grey[500],
      ),
    );
  }

  List<String> _getFilteredSubjects() {
    final allSubjects = _grouped.keys.toList();
    if (_searchQuery.isEmpty) return allSubjects;
    return allSubjects.where((subject) {
      final name = _getSubjectName(subject).toLowerCase();
      return name.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Получаем тему
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: isDark ? Colors.white70 : Colors.blue,
          ),
        ),
      );
    }

    final filteredSubjects = _getFilteredSubjects();

    return Scaffold(
      // 🔥 Динамический фон
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔍 Адаптивная панель поиска
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D44) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Поиск предмета...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey[600],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🏆 Карточка достижений (градиент универсальный)
              GestureDetector(
                onTap: () {
                  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AchievementsScreen(userId: userId),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          size: 40,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Достижения',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Смотри свои награды',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 📚 Адаптивный заголовок
              Text(
                'Предметы',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              filteredSubjects.isEmpty
                  ? Center(
                      child: Text(
                        'Ничего не найдено',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: filteredSubjects.length,
                      itemBuilder: (context, index) {
                        final courseId = filteredSubjects[index];
                        final lessons = _grouped[courseId]!;
                        final progress = _progress[courseId] ?? 0;
                        final progressPercent = lessons.isNotEmpty
                            ? progress / lessons.length
                            : 0.0;

                        return _buildSubjectCard(
                          courseId: courseId,
                          lessons: lessons,
                          progress: progressPercent,
                          isDark: isDark, // 🔥 Передаём тему
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 Карточка с параметром isDark
  Widget _buildSubjectCard({
    required String courseId,
    required List<LessonModel> lessons,
    required double progress,
    required bool isDark,
  }) {
    return GestureDetector(
      onTapDown: (_) => _onCardTapDown(courseId),
      onTapUp: (_) => _onCardTapUp(courseId),
      onTapCancel: () => _onCardTapUp(courseId),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SubjectScreen(courseId: courseId, lessons: lessons),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: 220,
        transform: _tilts[courseId] == true
            ? Matrix4.rotationZ(0.10)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          // 🔥 Адаптивный фон карточки
          color: isDark ? const Color(0xFF2D2D44) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 145,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                color: _getSubjectBgColor(courseId),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _buildSubjectImage(courseId),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getSubjectName(courseId),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: isDark
                                ? Colors.white24
                                : Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF667eea),
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF667eea),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final Map<String, bool> _tilts = {};
  void _onCardTapDown(String courseId) =>
      setState(() => _tilts[courseId] = true);
  void _onCardTapUp(String courseId) =>
      setState(() => _tilts[courseId] = false);
}
