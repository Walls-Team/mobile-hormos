// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:genius_hormo/features/auth/models/user_models.dart';
import 'user_storage_service.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3000';
  final UserStorageService _storageService;
  final http.Client _client;

  AuthService({
    UserStorageService? storageService,
    http.Client? client,
  })  : _storageService = storageService ?? UserStorageService(),
        _client = client ?? http.Client();

  /// Registro de nuevo usuario
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/v1/api/register'),
        headers: _getHeaders(),
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('📝 Register Response status: ${response.statusCode}');
      print('📝 Register Response body: ${response.body}');

      return _handleAuthResponse(response);
    } catch (e) {
      print('❌ Error en register: $e');
      return AuthResponse.error(message: 'Error de conexión: $e');
    }
  }

  /// Login de usuario
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/login'),
        headers: _getHeaders(),
        body: json.encode({'email': email, 'password': password}),
      );

      print('🔐 Login Response status: ${response.statusCode}');
      print('🔐 Login Response body: ${response.body}');

      return _handleAuthResponse(response);
    } catch (e) {
      print('❌ Error en login: $e');
      return AuthResponse.error(message: 'Error de conexión: $e');
    }
  }

  /// Obtener perfil del usuario
  Future<ApiResponse<User>> getMyProfile() async {
    try {
      final String? token = await _storageService.getToken();

      if (token == null || token.isEmpty) {
        return ApiResponse.error(message: 'No hay token de autenticación');
      }

      final response = await _client.get(
        Uri.parse('$_baseUrl/v1/api/me'),
        headers: _getHeaders(withAuth: true, token: token),
      );

      print('👤 Get My Profile Response status: ${response.statusCode}');
      print('👤 Get My Profile Response body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final String? error = responseData['error'];
        final bool hasError = error != null && error.isNotEmpty;

        if (!hasError && responseData['data'] != null) {
          final user = User.fromJson(responseData['data']);
          await _storageService.saveUserProfile(user);

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
          message: responseData['message'] ??
              responseData['error'] ??
              'Error al obtener el perfil - Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error en getMyProfile: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

  // ========== VERIFICACIÓN DE EMAIL ==========

  /// Verificar email con código OTP
  Future<ApiResponse<bool>> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/v1/api/verify-account'),
        headers: _getHeaders(),
        body: json.encode({'email': email, 'code': verificationCode}),
      );

      return _handleApiResponse<bool>(response, (data) => true);
    } catch (e) {
      print('❌ Error en verifyEmail: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

  /// Reenviar código OTP
  Future<ApiResponse<bool>> resendOtp({required String email}) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/v1/api/resend-otp'),
        headers: _getHeaders(),
        body: json.encode({'email': email, 'context': 'verify'}),
      );

      return _handleApiResponse<bool>(response, (data) => true);
    } catch (e) {
      print('❌ Error en resendOtp: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

  // ========== ACTUALIZACIÓN DE PERFIL ==========

  /// Actualizar perfil de usuario
  Future<ApiResponse<User>> updateProfile({
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final String? token = await _storageService.getToken();

      if (token == null) {
        return ApiResponse.error(message: 'No hay token de autenticación');
      }

      final response = await _client.put(
        Uri.parse('$_baseUrl/v1/api/me/update'),
        headers: _getHeaders(withAuth: true, token: token),
        body: json.encode(updateData),
      );

      print('📝 Update Profile Response status: ${response.statusCode}');
      print('📝 Update Profile Response body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final String? error = responseData['error'];
        final bool hasError = error != null && error.isNotEmpty;

        if (!hasError && responseData['data'] != null) {
          final user = User.fromJson(responseData['data']);
          await _storageService.saveUserProfile(user);

          return ApiResponse.success(
            message: responseData['message'] ?? 'Perfil actualizado exitosamente',
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
          message: responseData['message'] ??
              responseData['error'] ??
              'Error al actualizar el perfil - Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error en updateProfile: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

  // ========== RECUPERACIÓN DE CONTRASEÑA ==========

  /// Solicitar restablecimiento de contraseña
  Future<ApiResponse<bool>> requestPasswordReset({required String email}) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/v1/api/password-reset/request'),
        headers: _getHeaders(),
        body: json.encode({'email': email}),
      );

      return _handleApiResponse<bool>(response, (data) => true);
    } catch (e) {
      print('❌ Error en requestPasswordReset: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

  /// Validar OTP para restablecimiento
  Future<ApiResponse<bool>> validatePasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/v1/api/password-reset/validate-otp'),
        headers: _getHeaders(),
        body: json.encode({'email': email, 'code': otp}),
      );

      return _handleApiResponse<bool>(response, (data) => true);
    } catch (e) {
      print('❌ Error en validatePasswordResetOtp: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

  /// Confirmar restablecimiento de contraseña
  Future<ApiResponse<bool>> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/v1/api/password-reset/confirm'),
        headers: _getHeaders(),
        body: json.encode({
          'email': email,
          'code': otp,
          'password': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      return _handleApiResponse<bool>(response, (data) => true);
    } catch (e) {
      print('❌ Error en confirmPasswordReset: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

  // ========== DELEGACIÓN AL STORAGE SERVICE ==========

  /// Obtener usuario actual (delegado al storage service)
  Future<User?> getCurrentUser() => _storageService.getCurrentUser();

  /// Verificar si está logueado (delegado al storage service)
  Future<bool> isLoggedIn() => _storageService.isLoggedIn();

  /// Verificar si el perfil está completo (delegado al storage service)
  Future<bool> isProfileComplete() => _storageService.isProfileComplete();

  /// Logout (delegado al storage service)
  Future<void> logout() => _storageService.logout();

  /// Limpiar almacenamiento (delegado al storage service)
  Future<void> clearAllStorage() => _storageService.clearAllStorage();

  // ========== MÉTODOS PRIVADOS ==========

  /// Headers comunes para las requests
  Map<String, String> _getHeaders({bool withAuth = false, String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Manejo de respuestas de autenticación
  AuthResponse _handleAuthResponse(http.Response response) {
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (responseData['data'] != null && responseData['data']['success'] == true) {
        // Guardar datos en storage
        _storageService.saveUserData(responseData['data']);
        
        final user = User.fromJson(responseData['data']['user'] ?? {});
        final token = responseData['data']['access_token'];

        return AuthResponse.success(
          message: responseData['message'] ?? 'Operación exitosa',
          user: user,
          token: token,
        );
      } else {
        return AuthResponse.error(
          message: responseData['message'] ?? 'Error en la operación',
        );
      }
    } else {
      final errorData = json.decode(response.body);
      return AuthResponse.error(
        message: errorData['message'] ?? 'Error en la operación',
      );
    }
  }

  /// Manejo genérico de respuestas API
  ApiResponse<T> _handleApiResponse<T>(
    http.Response response,
    T Function(dynamic) dataMapper,
  ) {
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final String? error = responseData['error'];
      final bool hasError = error != null && error.isNotEmpty;

      if (!hasError) {
        return ApiResponse.success(
          message: responseData['message'] ?? 'Operación exitosa',
          data: dataMapper(responseData['data']),
        );
      } else {
        return ApiResponse.error(
          message: error ?? 'Error en la operación',
        );
      }
    } else {
      return ApiResponse.error(
        message: responseData['message'] ??
            responseData['error'] ??
            'Error en la operación - Código: ${response.statusCode}',
      );
    }
  }
}