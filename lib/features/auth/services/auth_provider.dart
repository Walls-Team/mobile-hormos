import 'dart:convert';
import 'package:genius_hormo/features/auth/models/user_models.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3000';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Solo 2 keys necesarias - todo está unificado
  static const String _jwtTokenKey = 'jwt_token';
  static const String _userDataKey = 'user_data'; // Aquí va TODO el user data

  // REGISTER
  Future<AuthResponse> register({
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

      print('Register Response status: ${response.statusCode}');
      print('Register Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['data'] != null &&
            responseData['data']['success'] == true) {
          await _saveUserData(responseData['data']);
          final user = User.fromJson(responseData['data']['user'] ?? {});
          final token = responseData['data']['access_token'];

          return AuthResponse.success(
            message: responseData['message'] ?? 'Registro exitoso',
            user: user,
            token: token,
          );
        } else {
          return AuthResponse.error(
            message: responseData['message'] ?? 'Error en el registro',
          );
        }
      } else {
        final errorData = json.decode(response.body);
        return AuthResponse.error(
          message: errorData['message'] ?? 'Error en el registro',
        );
      }
    } catch (e) {
      print('Error en register: $e');
      return AuthResponse.error(message: 'Error de conexión: $e');
    }
  }

  // LOGIN
  Future<AuthResponse> login(String email, String password) async {
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
          final user = User.fromJson(responseData['data']['user'] ?? {});
          final token = responseData['data']['access_token'];

          return AuthResponse.success(
            message: responseData['message'] ?? 'Login exitoso',
            user: user,
            token: token,
          );
        } else {
          return AuthResponse.error(
            message: responseData['message'] ?? 'Error en el login',
          );
        }
      } else {
        final errorData = json.decode(response.body);
        return AuthResponse.error(
          message: errorData['message'] ?? 'Error en el login',
        );
      }
    } catch (e) {
      return AuthResponse.error(message: 'Error de conexión: $e');
    }
  }

  // GET MY PROFILE
  Future<ApiResponse<User>> getMyProfile() async {
    try {
      final String? token = await _secureStorage.read(key: _jwtTokenKey);

      if (token == null || token.isEmpty) {
        return ApiResponse.error(message: 'No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/v1/api/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get My Profile Response status: ${response.statusCode}');
      print('Get My Profile Response body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final String? error = responseData['error'];
        final bool hasError = error != null && error.isNotEmpty;

        if (!hasError && responseData['data'] != null) {
          final user = User.fromJson(responseData['data']);
          await _saveUserProfile(user);

          return ApiResponse.success(
            message: responseData['message'] ?? 'Perfil obtenido exitosamente',
            data: user,
          );
        } else {
          return ApiResponse.error(
            message: error ?? 'Error al obtener el perfil',
          );
        }
      } else if (response.statusCode == 401) {
        return ApiResponse.error(
          message: 'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        return ApiResponse.error(
          message:
              responseData['message'] ??
              responseData['error'] ??
              'Error al obtener el perfil - Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error en getMyProfile: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

  // VERIFY EMAIL
  Future<ApiResponse<bool>> verifyEmail({
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

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final String? error = responseData['error'];
        final bool hasError = error != null && error.isNotEmpty;

        if (!hasError) {
          return ApiResponse.success(
            message:
                responseData['message'] ?? 'Cuenta verificada exitosamente',
            data: true,
          );
        } else {
          return ApiResponse.error(
            message: error ?? 'Error en la verificación',
          );
        }
      } else {
        return ApiResponse.error(
          message:
              responseData['message'] ??
              responseData['error'] ??
              'Error en la verificación - Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error en verifyEmail: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

  // RESEND OTP
  Future<ApiResponse<bool>> resendOtp({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/api/resend-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'context': 'verify'}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final String? error = responseData['error'];
        final bool hasError = error != null && error.isNotEmpty;

        if (!hasError) {
          return ApiResponse.success(
            message: responseData['message'] ?? 'Código reenviado exitosamente',
            data: true,
          );
        } else {
          return ApiResponse.error(
            message: error ?? 'Error al reenviar el código',
          );
        }
      } else {
        return ApiResponse.error(
          message:
              responseData['message'] ??
              responseData['error'] ??
              'Error al reenviar el código - Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error en resendOtp: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

  // OBTENER USUARIO ACTUAL
  Future<User?> getCurrentUser() async {
    try {
      final String? userDataString = await _secureStorage.read(
        key: _userDataKey,
      );
      final String? token = await _secureStorage.read(key: _jwtTokenKey);

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
      print('Error en getCurrentUser: $e');
      return null;
    }
  }

  // VERIFICAR SI ESTÁ LOGUEADO
  Future<bool> isLoggedIn() async {
    try {
      final String? token = await _secureStorage.read(key: _jwtTokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // VERIFICAR SI EL EMAIL ESTÁ VERIFICADO
  Future<bool> isEmailVerified() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // VERIFICAR SI EL PERFIL ESTÁ COMPLETO
  Future<bool> isProfileComplete() async {
    final user = await getCurrentUser();
    return user?.isProfileComplete ?? false;
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      // Solo 2 operaciones en lugar de 14
      await _secureStorage.delete(key: _jwtTokenKey);
      await _secureStorage.delete(key: _userDataKey);
      print('Datos de usuario eliminados');
    } catch (e) {
      print('Error durante logout: $e');
    }
  }

  // MÉTODOS PRIVADOS
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    if (userData['access_token'] != null) {
      await _secureStorage.write(
        key: _jwtTokenKey,
        value: userData['access_token'],
      );
    }

    if (userData['user'] != null) {
      final user = User.fromJson(userData['user']);
      await _saveUserProfile(user);
    }
  }

  Future<void> _saveUserProfile(User user) async {
    try {
      await _secureStorage.write(
        key: _userDataKey,
        value: json.encode(user.toJson()),
      );
      print('Perfil de usuario guardado: ${user.username}');
    } catch (e) {
      print('Error guardando perfil de usuario: $e');
    }
  }

  // En AuthService - agregar este método
  Future<ApiResponse<User>> updateProfile({
    required Map<String, dynamic> updateData,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/v1/api/me/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      print('Update Profile Response status: ${response.statusCode}');
      print('Update Profile Response body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final String? error = responseData['error'];
        final bool hasError = error != null && error.isNotEmpty;

        if (!hasError && responseData['data'] != null) {
          final user = User.fromJson(responseData['data']);
          await _saveUserProfile(user); // Guardar en SecureStorage

          return ApiResponse.success(
            message:
                responseData['message'] ?? 'Perfil actualizado exitosamente',
            data: user,
          );
        } else {
          return ApiResponse.error(
            message: error ?? 'Error al actualizar el perfil',
          );
        }
      } else if (response.statusCode == 401) {
        return ApiResponse.error(
          message: 'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        return ApiResponse.error(
          message:
              responseData['message'] ??
              responseData['error'] ??
              'Error al actualizar el perfil - Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error en updateProfile: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

// PASSWORD RESET - Solicitar código de verificación
Future<ApiResponse<bool>> requestPasswordReset({required String email}) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/api/password-reset/request'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email}),
    );

    print('Password Reset Request Response status: ${response.statusCode}');
    print('Password Reset Request Response body: ${response.body}');

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final String? error = responseData['error'];
      final bool hasError = error != null && error.isNotEmpty;

      if (!hasError) {
        return ApiResponse.success(
          message: responseData['message'] ?? 'Código de verificación enviado exitosamente',
          data: true,
        );
      } else {
        return ApiResponse.error(
          message: error ?? 'Error al solicitar el restablecimiento de contraseña',
        );
      }
    } else {
      return ApiResponse.error(
        message: responseData['message'] ?? 
                responseData['error'] ??
                'Error al solicitar restablecimiento - Código: ${response.statusCode}',
      );
    }
  } catch (e) {
    print('Error en requestPasswordReset: $e');
    return ApiResponse.error(
      message: 'Error de conexión: $e',
    );
  }
}

// VALIDATE OTP - Validar código de verificación
Future<ApiResponse<bool>> validatePasswordResetOtp({
  required String email,
  required String otp,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/api/password-reset/validate-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email, 'code': otp}),
    );

    print('Validate OTP Response status: ${response.statusCode}');
    print('Validate OTP Response body: ${response.body}');

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final String? error = responseData['error'];
      final bool hasError = error != null && error.isNotEmpty;

      if (!hasError) {
        return ApiResponse.success(
          message: responseData['message'] ?? 'Código validado exitosamente',
          data: true,
        );
      } else {
        return ApiResponse.error(
          message: error ?? 'Error al validar el código',
        );
      }
    } else {
      return ApiResponse.error(
        message: responseData['message'] ?? 
                responseData['error'] ??
                'Error al validar código - Código: ${response.statusCode}',
      );
    }
  } catch (e) {
    print('Error en validatePasswordResetOtp: $e');
    return ApiResponse.error(
      message: 'Error de conexión: $e',
    );
  }
}

// CONFIRM PASSWORD RESET - Confirmar nueva contraseña
Future<ApiResponse<bool>> confirmPasswordReset({
  required String email,
  required String otp,
  required String newPassword,
  required String confirmPassword,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/api/password-reset/confirm'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: json.encode({
        'email': email,
        'code': otp,
        'password': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    print('Confirm Password Reset Response status: ${response.statusCode}');
    print('Confirm Password Reset Response body: ${response.body}');

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final String? error = responseData['error'];
      final bool hasError = error != null && error.isNotEmpty;

      if (!hasError) {
        return ApiResponse.success(
          message: responseData['message'] ?? 'Contraseña restablecida exitosamente',
          data: true,
        );
      } else {
        return ApiResponse.error(
          message: error ?? 'Error al restablecer la contraseña',
        );
      }
    } else {
      return ApiResponse.error(
        message: responseData['message'] ?? 
                responseData['error'] ??
                'Error al restablecer contraseña - Código: ${response.statusCode}',
      );
    }
  } catch (e) {
    print('Error en confirmPasswordReset: $e');
    return ApiResponse.error(
      message: 'Error de conexión: $e',
    );
  }
}


}
