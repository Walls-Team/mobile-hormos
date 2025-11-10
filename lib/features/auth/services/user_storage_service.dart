// lib/services/user_storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genius_hormo/features/auth/models/user_models.dart';

class UserStorageService {
  static const String _jwtTokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _emailVerifiedKey = 'email_verified'; // Nuevo key
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveJWTToken(String token) async {
    await _secureStorage.write(key: _jwtTokenKey, value: token);
  }

  Future<String?> getJWTToken() async {
    return await _secureStorage.read(key: _jwtTokenKey);
  }

  Future<void> deleteJWTToken() async {
    await _secureStorage.delete(key: _jwtTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<void> saveUserProfile(User user) async {
    try {
      await _secureStorage.write(
        key: _userDataKey,
        value: json.encode(user.toJson()),
      );
      print('✅ Perfil de usuario guardado: ${user.username}');
    } catch (e) {
      print('❌ Error guardando perfil de usuario: $e');
      rethrow;
    }
  }

  /// Obtiene el usuario actual desde el almacenamiento
  Future<User?> getCurrentUser() async {
    try {
      final String? userDataString = await _secureStorage.read(
        key: _userDataKey,
      );
      final String? token = await getJWTToken();

      // Si no hay token, no hay usuario logueado
      if (token == null || token.isEmpty) {
        return null;
      }

      if (userDataString != null) {
        final Map<String, dynamic> userData = json.decode(userDataString);
        return User.fromJson(userData);
      }

      return null;
    } catch (e) {
      print('❌ Error en getCurrentUser: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final String? token = await getJWTToken();
      final bool loggedIn = token != null && token.isNotEmpty;
      print('🔐 Estado de login: $loggedIn');
      return loggedIn;
    } catch (e) {
      print('❌ Error en isLoggedIn: $e');
      return false;
    }
  }

  // Guardar estado de verificación
  Future<void> setEmailVerified(bool verified) async {
    await _secureStorage.write(
      key: _emailVerifiedKey,
      value: verified.toString(),
    );
  }

  // Verificar estado
  Future<bool> isEmailVerified() async {
    try {
      final String? verified = await _secureStorage.read(
        key: _emailVerifiedKey,
      );
      return verified == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Verifica si el perfil está completo
  Future<bool> isProfileComplete() async {
    final user = await getCurrentUser();
    return user?.isProfileComplete ?? false;
  }

  Future<void> clearAllStorage() async {
    try {
      await _secureStorage.deleteAll();
      print('✅ SecureStorage limpiado completamente');
    } catch (e) {
      print('❌ Error limpiando SecureStorage: $e');
      rethrow;
    }
  }

  // ========== MÉTODOS DE DIAGNÓSTICO ==========

  /// Obtiene información del almacenamiento para debugging
  Future<Map<String, dynamic>> getStorageInfo() async {
    final token = await getJWTToken();
    final user = await getCurrentUser();
    final is_email_verified = await isEmailVerified();

    return {
      'hasToken': token != null,
      'tokenLength': token?.length ?? 0,
      'hasUser': user != null,
      'username': user?.username,
      'email': user?.email,
      'emailVerified': is_email_verified,
    };
  }
}
