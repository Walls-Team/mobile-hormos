// lib/services/user_storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genius_hormo/features/auth/models/user_models.dart';

class UserStorageService {
  static const String _jwtTokenKey = 'jwt_token';
  static const String _userDataKey = 'user_data';
    static const String _emailVerifiedKey = 'email_verified'; // Nuevo key
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ========== OPERACIONES DE TOKEN ==========
  
  /// Guarda el token JWT en SecureStorage
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _jwtTokenKey, value: token);
  }

  /// Obtiene el token JWT almacenado
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _jwtTokenKey);
  }

  /// Elimina el token JWT
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _jwtTokenKey);
  }

  // ========== OPERACIONES DE USUARIO ==========
  
  /// Guarda los datos completos del usuario
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    if (userData['access_token'] != null) {
      await saveToken(userData['access_token']);
    }

    if (userData['user'] != null) {
      final user = User.fromJson(userData['user']);
      await saveUserProfile(user);
    }
  }

  /// Guarda el perfil del usuario
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
      final String? userDataString = await _secureStorage.read(key: _userDataKey);
      final String? token = await getToken();

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

  // ========== VERIFICACIONES DE ESTADO ==========
  
  /// Verifica si el usuario está logueado
  Future<bool> isLoggedIn() async {
    try {
      final String? token = await getToken();
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
      final String? verified = await _secureStorage.read(key: _emailVerifiedKey);
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

  // ========== OPERACIONES DE LIMPIEZA ==========
  
  /// Realiza logout eliminando todos los datos
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _jwtTokenKey);
      await _secureStorage.delete(key: _userDataKey);
      print('✅ Logout exitoso - datos de usuario eliminados');
    } catch (e) {
      print('❌ Error durante logout: $e');
      rethrow;
    }
  }

  /// Limpia todo el almacenamiento (para desarrollo)
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
    final token = await getToken();
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