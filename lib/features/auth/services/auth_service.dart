import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:genius_hormo/core/api/api_helpers.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/core/config/app_config.dart';
import 'package:genius_hormo/features/auth/dto/login_dto.dart';
import 'package:genius_hormo/features/auth/dto/register_dto.dart';
import 'package:genius_hormo/features/auth/dto/resend_otp.dart';
import 'package:genius_hormo/features/auth/dto/reset_password_dto.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';
import 'package:genius_hormo/features/auth/dto/verify-account_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/update_profile_dto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_storage_service.dart';

class AuthService {
  final UserStorageService _storageService;
  final http.Client _client;

  AuthService({UserStorageService? storageService, http.Client? client})
    : _storageService = storageService ?? UserStorageService(),
      _client = client ?? http.Client();

  Future<ApiResponse<RegisterResponseData>> register({
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

    final url = AppConfig.getApiUrl('register/');
    final body = json.encode({
      'username': username.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      "confirmPassword": password,
      "terms_and_conditions_accepted": true
    });

    debugPrint('🚀 REGISTER REQUEST');
    debugPrint('📍 URL: $url');
    debugPrint('📦 Body: $body');

    return executeRequest<RegisterResponseData>(
      request: _client
          .post(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(),
            body: body,
          )
          .timeout(AppConfig.defaultTimeout),
      fromJson: RegisterResponseData.fromJson,
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

    final url = AppConfig.getLoginUrl('login/');
    final body = json.encode({
      'email': email.trim().toLowerCase(),
      'password': password,
    });

    debugPrint('🚀 LOGIN REQUEST');
    debugPrint('📍 ENDPOINT: login/');
    debugPrint('📍 FULL URL: $url');
    debugPrint('📦 Body: $body');
    debugPrint('🔧 Probando con barra final (/)...');

    return executeRequest<LoginResponse>(
      request: _client
          .post(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(),
            body: body,
          )
          .timeout(AppConfig.defaultTimeout),
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

    final url = AppConfig.getApiUrl('verify-account/');
    final body = json.encode({'email': email, 'code': code});

    debugPrint('🚀 VERIFY EMAIL REQUEST');
    debugPrint('📍 URL: $url');
    debugPrint('📦 Body: $body');

    return executeRequest<VerifyAccountResponseData>(
      request: _client
          .post(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(),
            body: body,
          )
          .timeout(AppConfig.defaultTimeout),
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

    final url = AppConfig.getApiUrl('resend-otp/');
    final body = json.encode({'email': email, 'context': context});

    debugPrint('🚀 RESEND OTP REQUEST');
    debugPrint('📍 URL: $url');
    debugPrint('📦 Body: $body');

    return executeRequest<ResendOtpResponseData>(
      request: _client
          .post(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(),
            body: body,
          )
          .timeout(AppConfig.defaultTimeout),
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
            Uri.parse(AppConfig.getApiUrl('password-reset/request')),
            headers: AppConfig.getCommonHeaders(),
            body: json.encode({'email': email}),
          )
          .timeout(AppConfig.defaultTimeout),
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
            Uri.parse(AppConfig.getApiUrl('password-reset/validate-otp')),
            headers: AppConfig.getCommonHeaders(),
            body: json.encode({'email': email, 'code': code}),
          )
          .timeout(AppConfig.defaultTimeout),
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
            Uri.parse(AppConfig.getApiUrl('password-reset/confirm')),
            headers: AppConfig.getCommonHeaders(),
            body: json.encode({
              'email': email,
              'code': code,
              'password': newPassword,
              'confirmPassword': confirmPassword,
            }),
          )
          .timeout(AppConfig.defaultTimeout),
      fromJson: PasswordResetResponseData.fromJson,
    );
  }

  //===================
  Future<UserProfileData> getMyProfile({required String token}) async {
    final prefs = await SharedPreferences.getInstance();

    final cachedUserData = prefs.getString('cached_user_profile');

    if (cachedUserData != null) {
      debugPrint('📦 Usando perfil en caché');
      // Si hay cache, convertir de JSON a objeto User y retornar
      final userMap = json.decode(cachedUserData);
      final user = UserProfileData.fromJson(userMap);

      return user;
    } else {
      // Si NO hay cache, hacer request al backend
      try {
        final url = AppConfig.getApiUrl('me/');
        
        debugPrint('🚀 GET MY PROFILE REQUEST');
        debugPrint('📍 ENDPOINT: me');
        debugPrint('📍 FULL URL: $url');
        debugPrint('🔐 Token: ${token}...');

        final result = await executeRequest<UserProfileData>(
          request: _client
              .get(
                Uri.parse(url),
                headers: AppConfig.getCommonHeaders(withAuth: true, token: token),
              )
              .timeout(AppConfig.defaultTimeout),
          fromJson: UserProfileData.fromJson,
        );

        debugPrint('✅ PERFIL OBTENIDO');

        if (result.success && result.data != null) {
          debugPrint('💾 Guardando perfil en caché');
          final userJson = json.encode(result.data!.toJson());
          await prefs.setString('cached_user_profile', userJson);
        }

        return result.data!;
      } catch (e) {
        debugPrint('💥 ERROR AL OBTENER PERFIL: $e');
        // Si hay error en la API, propagar el error
        throw Exception('error al obtener los datos');
      }
    }
  }

  // Future<ApiResponse<User>> updateProfile({
  //   required Map<String, dynamic> updateData,
  // }) async {
  //   try {
  //     final String? token = await _storageService.getJWTToken();

  //     if (token == null) {
  //       return ApiResponse.error(message: 'No hay token de autenticación');
  //     }

  //     final response = await _client.put(
  //       Uri.parse('$_baseUrl/v1/api/me/update'),
  //       headers: _getHeaders(withAuth: true, token: token),
  //       body: json.encode(updateData),
  //     );

  //     print('📝 Update Profile Response status: ${response.statusCode}');
  //     print('📝 Update Profile Response body: ${response.body}');

  //     final Map<String, dynamic> responseData = json.decode(response.body);

  //     if (response.statusCode == 200) {
  //       final String? error = responseData['error'];
  //       final bool hasError = error != null && error.isNotEmpty;

  //       if (!hasError && responseData['data'] != null) {
  //         final user = User.fromJson(responseData['data']);
  //         await _storageService.saveUserProfile(user);

  //         return ApiResponse.success(
  //           message:
  //               responseData['message'] ?? 'Perfil actualizado exitosamente',
  //           data: user,
  //         );
  //       } else {
  //         return ApiResponse.error(
  //           message: error ?? 'Error al actualizar el perfil',
  //         );
  //       }
  //     } else if (response.statusCode == 401) {
  //       return ApiResponse.error(
  //         message: 'Sesión expirada. Por favor, inicia sesión nuevamente.',
  //       );
  //     } else {
  //       return ApiResponse.error(
  //         message:
  //             responseData['message'] ??
  //             responseData['error'] ??
  //             'Error al actualizar el perfil - Código: ${response.statusCode}',
  //       );
  //     }
  //   } catch (e) {
  //     print('❌ Error en updateProfile: $e');
  //     return ApiResponse.error(message: 'Error de conexión: $e');
  //   }
  // }

  /// Obtener usuario actual (delegado al storage service)
  // Future<User?> getCurrentUser() => _storageService.getCurrentUser();

  /// Verificar si está logueado (delegado al storage service)
  Future<bool> isLoggedIn() => _storageService.isLoggedIn();

  /// Verificar si el perfil está completo (delegado al storage service)
  Future<bool> isProfileComplete() => _storageService.isProfileComplete();

  /// Limpiar almacenamiento (delegado al storage service)
  Future<void> clearAllStorage() => _storageService.clearAllStorage();

  /// Actualizar perfil del usuario
  /// Endpoint: POST /v1/api/me/update/
  Future<UserProfileData> updateProfile({
    required String token,
    required UserProfileData updatedData,
  }) async {
    try {
      final url = AppConfig.getApiUrl('me/update/');
      
      // Construir body sin campos null
      final bodyMap = {
        'username': updatedData.username,
        'height': updatedData.height,
        'weight': updatedData.weight,
        'language': updatedData.language,
        'gender': updatedData.gender,
        'birth_date': updatedData.birthDate,
      };
      
      // Omitir age si es null
      if (updatedData.age != null) {
        bodyMap['age'] = updatedData.age;
      }
      
      final body = json.encode(bodyMap);

      debugPrint('🚀 UPDATE PROFILE REQUEST');
      debugPrint('📍 ENDPOINT: me/update/');
      debugPrint('📍 FULL URL: $url');
      debugPrint('📦 Body: $body');
      debugPrint('🔐 Token: ${token.substring(0, 20)}...');

      final response = await _client
          .post(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: token),
            body: body,
          )
          .timeout(AppConfig.defaultTimeout);

      debugPrint('📥 RESPONSE STATUS: ${response.statusCode}');
      debugPrint('📥 RESPONSE BODY: ${response.body}');

      final result = handleApiResponse<UserProfileData>(
        response,
        UserProfileData.fromJson,
      );

      if (!result.success) {
        throw Exception(result.message ?? 'Error al actualizar perfil');
      }

      debugPrint('✅ PERFIL ACTUALIZADO');

      if (result.data != null) {
        // Actualizar caché
        final prefs = await SharedPreferences.getInstance();
        final userJson = json.encode(result.data!.toJson());
        await prefs.setString('cached_user_profile', userJson);
        debugPrint('💾 Perfil en caché actualizado');
      }

      return result.data!;
    } catch (e) {
      debugPrint('💥 ERROR AL ACTUALIZAR PERFIL: $e');
      throw Exception('error al actualizar el perfil');
    }
  }

  // ========== MÉTODOS PRIVADOS ==========
  // Nota: _getHeaders fue reemplazado por AppConfig.getCommonHeaders()

  bool isValidEmail(String email) {
    // Expresión regular que permite:
    // - Caracteres alfanuméricos
    // - Puntos (.)
    // - Guiones (-)
    // - Guiones bajos (_)
    // - Signos más (+) - usado en Gmail para testing
    return RegExp(r'^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
}
