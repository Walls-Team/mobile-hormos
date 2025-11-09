import 'dart:async';
import 'dart:convert';
import 'package:genius_hormo/core/api/api_helpers.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/features/auth/dto/login_dto.dart';
import 'package:genius_hormo/features/auth/dto/resend_otp.dart';
import 'package:genius_hormo/features/auth/dto/reset_password_dto.dart';
import 'package:genius_hormo/features/auth/dto/verify-account_dto.dart';
import 'package:genius_hormo/features/auth/models/register_models.dart';
import 'package:genius_hormo/features/auth/models/user_models.dart';
import 'package:http/http.dart' as http;
import 'user_storage_service.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3000';
  final UserStorageService _storageService;
  final http.Client _client;

  AuthService({UserStorageService? storageService, http.Client? client})
    : _storageService = storageService ?? UserStorageService(),
      _client = client ?? http.Client();

  Future<ApiResponse<RegisterResponse>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      return ApiResponse.error(message: 'Todos los campos son requeridos');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Email inválido');
    }

    return executeRequest<RegisterResponse>(
      request: _client
          .post(
            Uri.parse('$_baseUrl/v1/api/register'),
            headers: _getHeaders(),
            body: json.encode({
              'username': username.trim(),
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: RegisterResponse.fromJson,
    );
  }

  Future<ApiResponse<LoginResponse>> login(
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      return ApiResponse.error(message: 'Todos los campos son requeridos');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Email inválido');
    }

    return executeRequest<LoginResponse>(
      request: _client
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: _getHeaders(),
            body: json.encode({
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: LoginResponse.fromJson,
    );
  }

  Future<ApiResponse<VerifyAccountResponseData>> verifyEmail({
    required String email,
    required String code,
  }) async {
    if (email.isEmpty || code.isEmpty) {
      return ApiResponse.error(message: 'Todos los campos son requeridos');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Email inválido');
    }

    return executeRequest<VerifyAccountResponseData>(
      request: _client
          .post(
            Uri.parse('$_baseUrl/v1/api/verify-account'),
            headers: _getHeaders(),
            body: json.encode({'email': email, 'code': code}),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: VerifyAccountResponseData.fromJson,
    );
  }

  Future<ApiResponse<ResendOtpResponseData>> resendOtp({
    required String email,
    required String context,
  }) async {
    if (email.isEmpty || context.isEmpty) {
      return ApiResponse.error(message: 'Todos los campos son requeridos');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Email inválido');
    }

    return executeRequest<ResendOtpResponseData>(
      request: _client
          .post(
            Uri.parse('$_baseUrl/v1/api/resend-otp'),
            headers: _getHeaders(),
            body: json.encode({'email': email, 'context': context}),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: ResendOtpResponseData.fromJson,
    );
  }

  Future<ApiResponse<PasswordResetResponseData>> requestPasswordReset({
    required String email,
  }) async {
    if (email.isEmpty) {
      return ApiResponse.error(message: 'Todos los campos son requeridos');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Email inválido');
    }

    return executeRequest<PasswordResetResponseData>(
      request: _client
          .post(
            Uri.parse('$_baseUrl/v1/api/password-reset/request'),
            headers: _getHeaders(),
            body: json.encode({'email': email}),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: PasswordResetResponseData.fromJson,
    );
  }

  Future<ApiResponse<PasswordResetResponseData>> validatePasswordResetOtp({
    required String email,
    required String code,
  }) async {
    if (email.isEmpty || code.isEmpty) {
      return ApiResponse.error(message: 'Todos los campos son requeridos');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Email inválido');
    }

    return executeRequest<PasswordResetResponseData>(
      request: _client
          .post(
            Uri.parse('$_baseUrl/v1/api/password-reset/validate-otp'),
            headers: _getHeaders(),
            body: json.encode({'email': email, 'code': code}),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: PasswordResetResponseData.fromJson,
    );
  }

  Future<ApiResponse<PasswordResetResponseData>> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (email.isEmpty ||
        code.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      return ApiResponse.error(message: 'Todos los campos son requeridos');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Email inválido');
    }

    return executeRequest<PasswordResetResponseData>(
      request: _client
          .post(
            Uri.parse('$_baseUrl/v1/api/password-reset/confirm'),
            headers: _getHeaders(),
            body: json.encode({
              'email': email,
              'code': code,
              'password': newPassword,
              'confirmPassword': confirmPassword,
            }),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: PasswordResetResponseData.fromJson,
    );
  }

  //===================

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
          message:
              responseData['message'] ??
              responseData['error'] ??
              'Error al obtener el perfil - Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error en getMyProfile: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

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
      print('❌ Error en updateProfile: $e');
      return ApiResponse.error(message: 'Error de conexión: $e');
    }
  }

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
      if (responseData['data'] != null &&
          responseData['data']['success'] == true) {
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
    // T Function(dynamic) dataMapper,
    T Function(Map<String, dynamic>) dataMapper,
  ) {
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final String? error = responseData['error'];
      final bool hasError = error != null && error.isNotEmpty;

      if (!hasError) {
        return ApiResponse.success(
          message: responseData['message'] ?? 'Operación exitosa',
          data: dataMapper(responseData['data']),
        );
      } else {
        return ApiResponse.error(message: error);
      }
    } else {
      return ApiResponse.error(
        message:
            responseData['message'] ??
            responseData['error'] ??
            'Error en la operación - Código: ${response.statusCode}',
      );
    }
  }

  bool isValidEmail(String email) {
    return true;
  }
}
