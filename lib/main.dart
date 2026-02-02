import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/login_screen.dart'; // Добавляем экран входа
import 'screens/register_screen.dart'; // Добавляем экран регистрации
import 'data_provider.dart';
import 'services/auth_service.dart'; // Добавляем сервис аутентификации

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Проверяем авторизацию при запуске
  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CurrencyData()..loadData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Currency & Crypto Tracker',
        theme: ThemeData.dark(),
        // Определяем начальный экран в зависимости от авторизации
        initialRoute: isLoggedIn ? '/' : '/login',
        routes: {
          '/': (context) => const HomeScreen(),
          '/converter': (context) => const ConverterScreen(),
          '/favorites': (context) => const FavoritesScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
        },
        // Альтернативный маршрут для 404 ошибок
        onGenerateRoute: (settings) {
          // Если пользователь пытается перейти на защищенный маршрут без авторизации
          if (!isLoggedIn &&
              (settings.name == '/' ||
                  settings.name == '/converter' ||
                  settings.name == '/favorites')) {
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          }
          return null;
        },
      ),
    );
  }
}