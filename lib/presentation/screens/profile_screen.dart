import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/auth_repository.dart';
import '../../core/services/theme_service.dart';
import '../../data/repositories/xp_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final XPRepository _xpRepo = XPRepository();
  int _totalXP = 0;
  int _level = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadXP();
  }

  Future<void> _loadXP() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final total = await _xpRepo.getTotalXP(userId);
      final level = await _xpRepo.getLevel(userId);

      if (mounted) {
        setState(() {
          _totalXP = total;
          _level = level;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Ошибка загрузки XP: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authRepo = AuthRepository();
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔝 Шапка с выходом
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Профиль',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.logout,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                    onPressed: () => authRepo.signOut(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 👤 Профиль пользователя
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF667eea),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email?.split('@').first ?? 'Пользователь',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                    onPressed: () => _showEditNameDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 🏆 Блок уровня и XP
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFFFFD700).withOpacity(0.3),
                            const Color(0xFFFFA500).withOpacity(0.2),
                          ]
                        : [const Color(0xFFFFF3CD), const Color(0xFFFFE69C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFFFFD700).withOpacity(0.3)
                        : const Color(0xFFFFE69C),
                    width: 1,
                  ),
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFFFFD700).withOpacity(0.2)
                                      : Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFB800),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Уровень $_level',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB8860B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$_totalXP XP',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFB800),
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'До уровня ${_level + 1}: ${100 - (_totalXP % 100)} XP',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFFB8860B).withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (_totalXP % 100) / 100,
                              backgroundColor: isDark
                                  ? Colors.white24
                                  : Colors.white70,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 32),

              // 📋 Быстрые действия
              Text(
                'Быстрые действия',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.emoji_events,
                      label: 'Достижения',
                      color: const Color(0xFF667eea),
                      onTap: () =>
                          Navigator.pushNamed(context, '/achievements'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.leaderboard,
                      label: 'Рейтинг',
                      color: const Color(0xFFBFD231),
                      onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.book, // 🔥 Иконка книги для Уроков
                      label: 'Уроки',
                      color: isDark
                          ? const Color(0xFF1F8EDD)
                          : const Color(0xFF509BDD),
                      onTap: () => Navigator.pushNamed(context, '/lessons'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ⚙️ Настройки профиля
              Text(
                'Настройки',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              _buildSettingsCard(
                icon: Icons.person_outline,
                title: 'Имя пользователя',
                subtitle: '@${user?.email?.split('@').first ?? "user"}',
                isDark: isDark,
                onTap: () => _showEditNameDialog(context),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                icon: Icons.notifications_outlined,
                title: 'Уведомления',
                subtitle: 'Настроить',
                isDark: isDark,
                onTap: () => _showNotificationsDialog(context),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                icon: Icons.lock_outline,
                title: 'Приватность',
                subtitle: '',
                isDark: isDark,
                onTap: () => _showPrivacyDialog(context),
              ),

              const SizedBox(height: 32),

              // 🌗 Переключатель темы
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D44) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Тёмная тема',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: isDark,
                      onChanged: (value) => themeService.toggleTheme(),
                      activeColor: const Color(0xFF667eea),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🚪 Кнопки выхода и смены аккаунта
              Text(
                'Личная информация',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _showSwitchAccountDialog(context),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Switch To Other Account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF667eea),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => authRepo.signOut(),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎴 Карточка быстрого действия
  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⚙️ Карточка настройки
  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D44) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF667eea).withOpacity(0.2)
                    : const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF667eea)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 Диалоги для настроек

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.email?.split('@').first,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Изменить имя'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Введите новое имя'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Сохранить имя в Firebase
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Имя обновлено!')));
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    bool pushEnabled = true;
    bool emailEnabled = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Уведомления'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.push_pin),
                title: const Text('Push-уведомления'),
                trailing: Switch(
                  value: pushEnabled,
                  onChanged: (v) => setState(() => pushEnabled = v),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email-уведомления'),
                trailing: Switch(
                  value: emailEnabled,
                  onChanged: (v) => setState(() => emailEnabled = v),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // TODO: Сохранить настройки уведомлений
                Navigator.pop(ctx);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Приватность'),
        content: const Text('Настройки приватности в разработке'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSwitchAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Смена аккаунта'),
        content: const Text('Выйдите и войдите под другим аккаунтом'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              AuthRepository().signOut();
              Navigator.pop(ctx);
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
