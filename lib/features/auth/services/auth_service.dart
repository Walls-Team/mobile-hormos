import 'dart:async';
import 'dart:convert';
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

    return executeRequest<RegisterResponseData>(
      request: _client
          .post(
            Uri.parse(AppConfig.getApiUrl('register')),
            headers: AppConfig.getCommonHeaders(),
            body: json.encode({
              'username': username.trim(),
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
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

    return executeRequest<LoginResponse>(
      request: _client
          .post(
            Uri.parse(AppConfig.getBaseUrl('login')),
            headers: AppConfig.getCommonHeaders(),
            body: json.encode({
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
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

    return executeRequest<VerifyAccountResponseData>(
      request: _client
          .post(
            Uri.parse(AppConfig.getApiUrl('verify-account')),
            headers: AppConfig.getCommonHeaders(),
            body: json.encode({'email': email, 'code': code}),
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

    return executeRequest<ResendOtpResponseData>(
      request: _client
          .post(
            Uri.parse(AppConfig.getApiUrl('resend-otp')),
            headers: AppConfig.getCommonHeaders(),
            body: json.encode({'email': email, 'context': context}),
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
      // Si hay cache, convertir de JSON a objeto User y retornar
      final userMap = json.decode(cachedUserData);
      final user = UserProfileData.fromJson(userMap);

      // return ApiResponse<UserProfileData>(
      //   data: user,
      //   success: true,
      //   message: '',
      // );

      return user;
    } else {
      // Si NO hay cache, hacer request al backend
      try {
        final result = await executeRequest<UserProfileData>(
          request: _client
              .get(
                Uri.parse(AppConfig.getApiUrl('me')),
                headers: AppConfig.getCommonHeaders(withAuth: true, token: token),
              )
              .timeout(AppConfig.defaultTimeout),
          fromJson: UserProfileData.fromJson,
        );

        if (result.success && result.data != null) {
          final userJson = json.encode(result.data!.toJson());
          await prefs.setString('cached_user_profile', userJson);
        }

        return result.data!;
      } catch (e) {
        // Si hay error en la API, propagar el error
        // return ApiResponse<UserProfileData>(
        //   error: e.toString(),
        //   success: false,
        //   message: '',
        // );

        throw Exception('error al obtener los datos');
      }
    }
  }

  Future<ApiResponse<UpdateProfileResponseData>> updateProfile(token) async {
    return executeRequest<UpdateProfileResponseData>(
      request: _client
          .get(
            Uri.parse(AppConfig.getApiUrl('me/update')),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: token),
          )
          .timeout(AppConfig.defaultTimeout),
      fromJson: UpdateProfileResponseData.fromJson,
    );
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

  // ========== MÉTODOS PRIVADOS ==========
  // Nota: _getHeaders fue reemplazado por AppConfig.getCommonHeaders()

  bool isValidEmail(String email) {
    return true;
  }
}
