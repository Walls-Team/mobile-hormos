import 'package:flutter/foundation.dart';
import 'package:genius_hormo/core/api/api_helpers.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/core/config/app_config.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Ejemplo de cómo usar el mecanismo de refresh token con executeAuthenticatedRequest
/// 
/// Este ejemplo muestra cómo obtener el perfil del usuario con manejo automático
/// de token expirado. Si el token está expirado, se refrescará automáticamente
/// y se reintentará la solicitud sin intervención adicional.
Future<ApiResponse<UserProfileData>> getMyProfileWithTokenRefresh() async {
  try {
    return await executeAuthenticatedRequest<UserProfileData>(
      // Esta función lambda recibe el token (ya sea el original o uno refrescado)
      requestWithToken: (token) async {
        final url = AppConfig.getApiUrl('me/');
        final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);
        
        debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🚀 GET MY PROFILE REQUEST (con refresh token automático)');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('📍 ENDPOINT: me/');
        debugPrint('🌐 FULL URL: $url');
        
        // Ejecutar la petición HTTP
        return await http.get(
          Uri.parse(url),
          headers: headers,
        ).timeout(AppConfig.defaultTimeout);
      },
      // Función para convertir el JSON a nuestro modelo
      fromJson: UserProfileData.fromJson,
    );
  } catch (e, stackTrace) {
    debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('💥 ERROR EN getMyProfileWithTokenRefresh');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ Error: $e');
    debugPrint('📍 StackTrace: $stackTrace');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    return ApiResponse.error(message: 'Error al obtener perfil: $e');
  }
}

/// Ejemplo de cómo migrar una función existente para usar el mecanismo de refresh token
/// 
/// Antes:
/// ```dart
/// Future<UserProfileData> getMyProfile({required String token}) async {
///   final url = AppConfig.getApiUrl('me/');
///   final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);
///   
///   final response = await _client.get(
///     Uri.parse(url),
///     headers: headers,
///   );
///   
///   // Manejar respuesta...
/// }
/// ```
/// 
/// Después:
/// ```dart
/// Future<UserProfileData> getMyProfile() async {
///   final response = await executeAuthenticatedRequest<UserProfileData>(
///     requestWithToken: (token) async {
///       final url = AppConfig.getApiUrl('me/');
///       final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);
///       
///       return await _client.get(
///         Uri.parse(url),
///         headers: headers,
///       );
///     },
///     fromJson: UserProfileData.fromJson,
///   );
///   
///   if (response.success && response.data != null) {
///     return response.data!;
///   } else {
///     throw Exception(response.message ?? 'Error al obtener perfil');
///   }
/// }
/// ```
/// 
/// Principales cambios:
/// 1. Ya no es necesario pasar el token como parámetro
/// 2. Se usa executeAuthenticatedRequest que maneja automáticamente el token
/// 3. La función ahora recibe como parámetro una función que recibe el token
/// 4. Se manejará automáticamente el refresh token si ocurre un error 401
