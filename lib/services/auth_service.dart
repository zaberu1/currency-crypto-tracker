import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthResult {
  final bool success;
  final String message;

  AuthResult({required this.success, required this.message});
}

class AuthService {
  static const String _usersKey = 'stored_users';
  static const String _currentUserKey = 'current_user';

  // Хэширование пароля с использованием SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Регистрация нового пользователя
  Future<AuthResult> register(String username, String password) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        return AuthResult(
          success: false,
          message: 'Логин и пароль не могут быть пустыми',
        );
      }

      final prefs = await SharedPreferences.getInstance();

      // Получаем существующих пользователей
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(json.decode(usersJson));

      // Проверяем, существует ли пользователь
      if (users.containsKey(username)) {
        return AuthResult(
          success: false,
          message: 'Пользователь с таким логином уже существует',
        );
      }

      // Хэшируем пароль и сохраняем пользователя
      final hashedPassword = _hashPassword(password);
      users[username] = hashedPassword;

      // Сохраняем обновленный список пользователей
      await prefs.setString(_usersKey, json.encode(users));

      return AuthResult(
        success: true,
        message: 'Регистрация успешна!',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Ошибка регистрации: ${e.toString()}',
      );
    }
  }

  // Вход пользователя
  Future<AuthResult> login(String username, String password) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        return AuthResult(
          success: false,
          message: 'Введите логин и пароль',
        );
      }

      final prefs = await SharedPreferences.getInstance();

      // Получаем существующих пользователей
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(json.decode(usersJson));

      // Проверяем, существует ли пользователь
      if (!users.containsKey(username)) {
        return AuthResult(
          success: false,
          message: 'Пользователь не найден',
        );
      }

      // Проверяем пароль
      final hashedPassword = _hashPassword(password);
      final storedHash = users[username] as String;

      if (hashedPassword == storedHash) {
        // Сохраняем информацию о текущем пользователе
        await prefs.setString(_currentUserKey, username);

        return AuthResult(
          success: true,
          message: 'Вход выполнен успешно',
        );
      } else {
        return AuthResult(
          success: false,
          message: 'Неверный пароль',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Ошибка входа: ${e.toString()}',
      );
    }
  }

  // Выход пользователя
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Проверка, авторизован ли пользователь
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString(_currentUserKey);
    return currentUser != null && currentUser.isNotEmpty;
  }

  // Получение текущего пользователя
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // Удаление пользователя (для отладки)
  Future<void> clearAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentUserKey);
  }
}