import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Locale;
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
import 'package:get_it/get_it.dart';
import 'package:genius_hormo/providers/lang_service.dart';
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
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      return ApiResponse.error(message: 'All fields are required');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Invalid email');
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
      return ApiResponse.error(message: 'All fields are required');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Invalid email');
    }

    final url = AppConfig.getLoginUrl('login');
    final body = json.encode({
      'email': email.trim().toLowerCase(),
      'password': password,
    });

    debugPrint('🚀 LOGIN REQUEST');
    debugPrint('📍 ENDPOINT: login');
    debugPrint('📍 FULL URL: $url');
    debugPrint('📦 Body: $body');

    return executeRequest<LoginResponse>(
      request: _client
          .post(
            Uri.parse("http://api-staging.geniushpro.com/v1/api/login/"),
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
      return ApiResponse.error(message: 'All fields are required');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Invalid email');
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
      return ApiResponse.error(message: 'All fields are required');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Invalid email');
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
      return ApiResponse.error(message: 'All fields are required');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Invalid email');
    }

    return executeRequest<PasswordResetResponseData>(
      request: _client
          .post(
            Uri.parse(AppConfig.getApiUrl('password-reset/request/')),
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
      return ApiResponse.error(message: 'All fields are required');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Invalid email');
    }

    return executeRequest<PasswordResetResponseData>(
      request: _client
          .post(
            Uri.parse(AppConfig.getApiUrl('password-reset/validate-otp/')),
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
      return ApiResponse.error(message: 'All fields are required');
    }

    if (!isValidEmail(email)) {
      return ApiResponse.error(message: 'Invalid email');
    }

    debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔐 PASSWORD RESET CONFIRM REQUEST');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📧 Email: $email');
    debugPrint('🔢 Code: $code');
    debugPrint('🔒 Password Length: ${newPassword.length}');
    debugPrint('📍 Endpoint: password-reset/confirm/');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    return executeRequest<PasswordResetResponseData>(
      request: _client
          .post(
            Uri.parse(AppConfig.getApiUrl('password-reset/confirm/')),
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

    // SIEMPRE hacer request para debugging (comentar el caché temporalmente)
    // if (cachedUserData != null) {
    //   debugPrint('📦 Usando perfil en caché');
    //   final userMap = json.decode(cachedUserData);
    //   final user = UserProfileData.fromJson(userMap);
    //   return user;
    // }

    try {
      final url = AppConfig.getApiUrl('me/');
      final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🚀 GET MY PROFILE REQUEST');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 ENDPOINT: me/');
      debugPrint('🌐 FULL URL: $url');
      debugPrint('📤 HEADERS:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          debugPrint('   $key: Bearer ${token.substring(0, 20)}...');
        } else {
          debugPrint('   $key: $value');
        }
      });
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final result = await executeRequest<UserProfileData>(
        request: _client
            .get(
              Uri.parse(url),
              headers: headers,
            )
            .timeout(AppConfig.defaultTimeout),
        fromJson: UserProfileData.fromJson,
      );

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📥 RESPONSE FROM getMyProfile');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ Success: ${result.success}');
      debugPrint('📝 Message: ${result.message}');
      
      if (result.success && result.data != null) {
        final userData = result.data!;
        debugPrint('\n👤 USER DATA OBJECT:');
        debugPrint('   userDATA: ${result}');
        debugPrint('   Username: ${userData.username}');
        debugPrint('   Email: ${userData.email}');
        debugPrint('   Avatar: ${userData.avatar}');
        debugPrint('   Height: ${userData.height}');
        debugPrint('   Weight: ${userData.weight}');
        debugPrint('   Gender: ${userData.gender}');
        debugPrint('   BirthDate: ${userData.birthDate}');
        debugPrint('   Language: ${userData.language}');
        debugPrint('   Age: ${userData.age}');
        debugPrint('   Is Complete: ${userData.isComplete}');
        debugPrint('   Completion %: ${userData.profileCompletionPercentage}');
        
        debugPrint('\n💾 Guardando perfil en caché...');
        final userJson = json.encode(userData.toJson());
        await prefs.setString('cached_user_profile', userJson);
        debugPrint('✅ Caché actualizado');
        
        // Setear idioma del usuario
        final userLanguage = userData.language;
        if (userLanguage != null && userLanguage.isNotEmpty) {
          try {
            final languageService = GetIt.instance<LanguageService>();
            final currentLang = await languageService.getCurrentLanguage();
            if (currentLang.languageCode != userLanguage) {
              debugPrint('🌐 Aplicando idioma del usuario: $userLanguage');
              await languageService.changeLanguage(Locale(userLanguage));
            }
          } catch (e) {
            debugPrint('⚠️ Error al setear idioma del usuario: $e');
          }
        }
      } else {
        debugPrint('❌ Error: ${result.error}');
        throw Exception('Error al obtener perfil: ${result.error ?? "No data received"}');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return result.data!;
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💥 ERROR EN getMyProfile');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Error al obtener perfil: $e');
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
      final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);
      
      // Construir body con campos del perfil
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

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🚀 UPDATE PROFILE REQUEST');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 ENDPOINT: me/update/');
      debugPrint('🌐 FULL URL: $url');
      debugPrint('📤 HEADERS:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          debugPrint('   $key: Bearer ${token.substring(0, 20)}...');
        } else {
          debugPrint('   $key: $value');
        }
      });
      debugPrint('\n📦 REQUEST BODY (JSON):');
      debugPrint(body);
      debugPrint('\n📋 DATOS A ACTUALIZAR:');
      debugPrint('   Username: ${updatedData.username}');
      debugPrint('   Email: ${updatedData.email}');
      debugPrint('   Height: ${updatedData.height}');
      debugPrint('   Weight: ${updatedData.weight}');
      debugPrint('   Gender: ${updatedData.gender}');
      debugPrint('   BirthDate: ${updatedData.birthDate}');
      debugPrint('   Language: ${updatedData.language}');
      debugPrint('   Age: ${updatedData.age}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(AppConfig.defaultTimeout);

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📥 RESPONSE FROM updateProfile');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body:');
      debugPrint(response.body);
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final result = handleApiResponse<UserProfileData>(
        response,
        UserProfileData.fromJson,
      );

      if (!result.success) {
        debugPrint('\n❌ UPDATE FAILED:');
        debugPrint('   Message: ${result.message}');
        debugPrint('   Error: ${result.error}\n');
        throw Exception(result.message ?? 'Error al actualizar perfil');
      }

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ PERFIL ACTUALIZADO EXITOSAMENTE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (result.data != null) {
        final userData = result.data!;
        debugPrint('\n👤 UPDATED USER DATA OBJECT:');
        debugPrint('   ID: ${userData.id}');
        debugPrint('   Username: ${userData.username}');
        debugPrint('   Email: ${userData.email}');
        debugPrint('   Height: ${userData.height}');
        debugPrint('   Weight: ${userData.weight}');
        debugPrint('   Gender: ${userData.gender}');
        debugPrint('   BirthDate: ${userData.birthDate}');
        debugPrint('   Language: ${userData.language}');
        debugPrint('   Age: ${userData.age}');
        debugPrint('   Is Complete: ${userData.isComplete}');
        debugPrint('   Completion %: ${userData.profileCompletionPercentage}');
        
        // Actualizar caché
        debugPrint('\n💾 Guardando perfil en caché...');
        final prefs = await SharedPreferences.getInstance();
        final userJson = json.encode(userData.toJson());
        await prefs.setString('cached_user_profile', userJson);
        debugPrint('✅ Caché actualizado');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return result.data!;
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💥 ERROR EN updateProfile');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Actualizar idioma del usuario
  /// Endpoint: POST /v1/api/me/update/
  Future<void> updateLanguage({
    required String token,
    required String language,
  }) async {
    try {
      final url = AppConfig.getApiUrl('me/update/');
      final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);
      
      final body = json.encode({
        'language': language,
      });

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🌐 UPDATE LANGUAGE REQUEST');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 ENDPOINT: me/update/');
      debugPrint('🌐 FULL URL: $url');
      debugPrint('📦 REQUEST BODY: $body');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(AppConfig.defaultTimeout);

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📥 RESPONSE FROM updateLanguage');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode != 200) {
        throw Exception('Failed to update language: ${response.statusCode}');
      }

      debugPrint('✅ Idioma actualizado exitosamente en el servidor');
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💥 ERROR EN updateLanguage');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Error al actualizar idioma: $e');
    }
  }

  bool isValidEmail(String email) {
    // More permissive regular expression that allows:
    // - Alphanumeric characters
    // - Dots (.)
    // - Hyphens (-)
    // - Underscores (_)
    // - Plus signs (+) - used in Gmail for testing
    return RegExp(r'^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Actualizar avatar del usuario
  /// Endpoint: POST /v1/api/me/avatar/
  Future<ApiResponse<void>> updateAvatar({
    required String token,
    required String avatarUrl,
  }) async {
    try {
      final url = AppConfig.getApiUrl('me/avatar/');
      final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);
      
      final body = json.encode({
        'avatar': avatarUrl,
      });

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🖼️  UPDATE AVATAR REQUEST');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 ENDPOINT: me/avatar/');
      debugPrint('🌐 FULL URL: $url');
      debugPrint('📦 BODY: $body');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(AppConfig.defaultTimeout);

      debugPrint('\n📥 RESPONSE FROM updateAvatar');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ AVATAR ACTUALIZADO EXITOSAMENTE\n');
        return ApiResponse.success(message: 'Avatar updated successfully', data: null);
      } else {
        return ApiResponse.error(message: 'Error updating avatar');
      }
    } catch (e) {
      debugPrint('❌ Error updating avatar: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Eliminar cuenta del usuario
  /// Endpoint: DELETE /v1/api/delete-account/
  Future<ApiResponse<void>> deleteAccount({
    required String token,
  }) async {
    try {
      final url = AppConfig.getApiUrl('delete-account/');
      final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🗑️  DELETE ACCOUNT REQUEST');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 ENDPOINT: delete-account/');
      debugPrint('🌐 FULL URL: $url');
      debugPrint('🔧 METHOD: DELETE');
      debugPrint('📤 HEADERS:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          debugPrint('   $key: Bearer ${token.substring(0, 20)}...');
        } else {
          debugPrint('   $key: $value');
        }
      });
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final response = await _client
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.defaultTimeout);

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📥 DELETE ACCOUNT RESPONSE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body:');
      debugPrint(response.body);
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // Aceptar 200, 204 (No Content), y 202 (Accepted)
      if (response.statusCode == 200 || 
          response.statusCode == 204 || 
          response.statusCode == 202) {
        
        String message = 'Account deleted successfully';
        
        if (response.statusCode != 204 && response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> responseData = json.decode(response.body);
            message = responseData['message']?.toString() ?? message;
            
            // Verificar si hay error en la respuesta
            final error = responseData['error']?.toString() ?? '';
            if (error.isNotEmpty) {
              debugPrint('❌ Error en respuesta: $error');
              return ApiResponse.error(message: error);
            }
          } catch (e) {
            debugPrint('⚠️ No se pudo parsear la respuesta, pero status code es exitoso');
          }
        }
        
        debugPrint('✅ CUENTA ELIMINADA EXITOSAMENTE\n');

        return ApiResponse.success(
          message: message,
          data: null,
        );
      } else {
        String errorMessage = 'Error ${response.statusCode}';
        
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          errorMessage = responseData['error']?.toString() ?? 
                        responseData['message']?.toString() ?? 
                        errorMessage;
        } catch (e) {
          errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
        }
        
        debugPrint('❌ $errorMessage');
        return ApiResponse.error(message: errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💥 ERROR EN DELETE ACCOUNT');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return ApiResponse.error(message: 'Error deleting account: $e');
    }
  }
}
