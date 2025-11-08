// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3000/v1/api'; // Cambia por tu URL
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // REGISTER - Conectado a tu backend
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Verificar si la respuesta tiene la estructura esperada
        if (responseData['data'] != null && responseData['data']['success'] == true) {
          // Guardar datos del usuario después del registro exitoso
          await _saveUserData(responseData['data']);
          
          return {
            'success': true,
            'data': responseData['data'],
            'message': responseData['message'] ?? 'Registro exitoso',
          };
        } else {
          return {
            'success': false,
            'error': responseData['message'] ?? 'Error en el registro',
          };
        }
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      print('Error en register: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // LOGIN - Para completar el flujo
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['data'] != null && responseData['data']['success'] == true) {
          await _saveUserData(responseData['data']);
          
          return {
            'success': true,
            'data': responseData['data'],
            'message': responseData['message'] ?? 'Login exitoso',
          };
        } else {
          return {
            'success': false,
            'error': responseData['message'] ?? 'Error en el login',
          };
        }
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Error en el login',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Guardar datos del usuario
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    // Guardar JWT de forma segura
    if (userData['access_token'] != null) {
      await _secureStorage.write(
        key: 'jwt_token', 
        value: userData['access_token']
      );
    }

    // Guardar otros datos del usuario en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    if (userData['user'] != null) {
      final user = userData['user'];
      await prefs.setString('user_id', user['id']?.toString() ?? '');
      await prefs.setString('user_email', user['email'] ?? '');
      await prefs.setString('user_name', user['username'] ?? '');
      await prefs.setString('profile_id', user['profile_id']?.toString() ?? '');
      await prefs.setBool('spike_connect', user['spike_connect'] ?? false);
    }

    // Guardar todos los datos de respuesta
    await prefs.setString('user_data', json.encode(userData));
    await prefs.setBool('is_logged_in', true);
  }

  // Obtener usuario actual
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (!isLoggedIn) return null;

      final String? userDataString = prefs.getString('user_data');
      final String? token = await _secureStorage.read(key: 'jwt_token');

      if (userDataString != null && token != null) {
        final Map<String, dynamic> userData = json.decode(userDataString);
        return {
          'token': token,
          'user': userData['user'] ?? {},
          'email': prefs.getString('user_email'),
          'username': prefs.getString('user_name'),
          'user_id': prefs.getString('user_id'),
          'profile_id': prefs.getString('profile_id'),
          'spike_connect': prefs.getBool('spike_connect') ?? false,
        };
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Verificar si está logueado
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final String? token = await _secureStorage.read(key: 'jwt_token');
      return isLoggedIn && token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'jwt_token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('profile_id');
      await prefs.remove('user_data');
      await prefs.remove('spike_connect');
      await prefs.setBool('is_logged_in', false);
    } catch (e) {
      print('Error durante logout: $e');
    }
  }
}