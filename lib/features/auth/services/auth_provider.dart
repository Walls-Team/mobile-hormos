// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3000'; // Cambia por tu URL
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // REGISTER - Conectado a tu backend
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/api/register'),
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
        if (responseData['data'] != null &&
            responseData['data']['success'] == true) {
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
      return {'success': false, 'error': 'Error de conexión: $e'};
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
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['data'] != null &&
            responseData['data']['success'] == true) {
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
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Guardar datos del usuario
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    // Guardar JWT de forma segura
    if (userData['access_token'] != null) {
      await _secureStorage.write(
        key: 'jwt_token',
        value: userData['access_token'],
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

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/api/verify-account'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'code': verificationCode}),
      );

      print('Verify Email Response status: ${response.statusCode}');
      print('Verify Email Response body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      // Lógica basada en el formato: {message: "", error: "", data: {}}
      if (response.statusCode == 200) {
        // Verificar si hay error vacío o nulo
        final String? error = responseData['error'];
        final bool hasError = error != null && error.isNotEmpty;

        if (!hasError) {
          // Si la verificación fue exitosa, actualizar el estado del usuario
          await _updateUserVerificationStatus();

          return {
            'success': true,
            'message':
                responseData['message'] ??
                responseData['data']?['message'] ??
                'Cuenta verificada exitosamente',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'error': error ?? 'Error en la verificación',
          };
        }
      } else {
        // Para códigos de error HTTP
        return {
          'success': false,
          'error':
              responseData['message'] ??
              responseData['error'] ??
              'Error en la verificación - Código: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error en verifyEmail: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Método auxiliar para actualizar el estado de verificación
  Future<void> _updateUserVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      final Map<String, dynamic> userData = json.decode(userDataString);

      // Actualizar el estado de verificación en los datos del usuario
      if (userData['user'] != null) {
        userData['user']['email_verified'] = true;
        userData['user']['verified'] = true;

        // Guardar los datos actualizados
        await prefs.setString('user_data', json.encode(userData));
      }
    }
  }

  // Método para verificar si el email está verificado
  Future<bool> isEmailVerified() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final Map<String, dynamic> userData = json.decode(userDataString);
        final user = userData['user'];

        return user['email_verified'] == true ||
            user['verified'] == true ||
            user['is_verified'] == true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // RESEND OTP - Reenviar código de verificación
  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/api/resend-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'context': 'verify'}),
      );

      print('Resend OTP Response status: ${response.statusCode}');
      print('Resend OTP Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Verificar éxito basado en el formato de respuesta
        if (responseData['error'] == null || responseData['error'].isEmpty) {
          return {
            'success': true,
            'message':
                responseData['message'] ?? 'Código reenviado exitosamente',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'error': responseData['error'] ?? 'Error al reenviar el código',
          };
        }
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error':
              errorData['message'] ??
              errorData['error'] ??
              'Error al reenviar el código - Código: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error en resendOtp: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
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
