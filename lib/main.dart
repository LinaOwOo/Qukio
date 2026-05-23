import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:qukio/presentation/screens/leaderboard_screen.dart';
import 'package:qukio/presentation/screens/lessons_screen.dart';

import 'firebase_options.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/achievements_screen.dart'; // ← ДОБАВЬ ЭТУ СТРОКУ
import 'core/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const QurioApp(),
    ),
  );
}

class QurioApp extends StatelessWidget {
  const QurioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'Qurio',
      debugShowCheckedModeBanner: false,

      themeMode: themeService.mode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),

      // 🔗 Маршруты
      routes: {
        '/achievements': (context) {
          final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
          return AchievementsScreen(userId: userId);
        },
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/lessons': (context) => const LessonsListScreen(),
      },

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
