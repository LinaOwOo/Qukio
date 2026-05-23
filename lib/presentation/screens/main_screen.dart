import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🔥 Добавь этот импорт
import 'home_screen.dart';
import 'profile_screen.dart';
import '../../core/services/theme_service.dart'; // 🔥 И сервис тем

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  final List<Widget> _pages = [const HomeScreen(), const ProfileScreen()];

  void _onTap(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    // 🔥 Получаем тему
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDark;

    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTap,
        // 🔥 Адаптивный фон навигации
        backgroundColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
        indicatorColor: const Color(0xFF764ba2).withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              // 🔥 Адаптивный цвет иконок
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
            selectedIcon: Icon(
              Icons.home,
              color: isDark ? Colors.white : const Color(0xFF764ba2),
            ),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outlined,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
            selectedIcon: Icon(
              Icons.person,
              color: isDark ? Colors.white : const Color(0xFF764ba2),
            ),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
