import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:genius_hormo/core/api/api_helpers.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/core/config/app_config.dart';
import 'package:http/http.dart' as http;

/// Servicio para interactuar con los endpoints de notificaciones del backend
class NotificationApiService {
  final http.Client _client;

  NotificationApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Registrar un token de dispositivo (FCM) en el backend
  /// 
  /// [token] - Firebase Cloud Messaging token del dispositivo
  /// [authToken] - JWT de autenticación del usuario
  /// [deviceInfo] - Información adicional del dispositivo (opcional)
  Future<ApiResponse<bool>> registerDeviceToken({
    required String token,
    required String authToken,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final url = AppConfig.getApiUrl('notifications/device/');
      
      final Map<String, dynamic> body = {
        'token': token,
        'platform': _getPlatform(),
      };
      
      // Añadir información del dispositivo si está disponible
      if (deviceInfo != null) {
        body['deviceInfo'] = deviceInfo;
      }
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔔 REGISTRANDO TOKEN DE DISPOSITIVO');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 URL: $url');
      debugPrint('🎫 Token: ${token.substring(0, 20)}...');
      debugPrint('📱 Plataforma: ${_getPlatform()}');
      
      final response = await _client
          .post(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: authToken),
            body: json.encode(body),
          )
          .timeout(AppConfig.defaultTimeout);
          
      debugPrint('📥 Respuesta: ${response.statusCode}');
      debugPrint('📄 Cuerpo: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(
          data: true,
          message: 'Token registrado correctamente',
        );
      } else {
        return ApiResponse.error(
          message: 'Error al registrar token: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ ERROR REGISTRANDO TOKEN');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      
      return ApiResponse.error(
        message: 'Error al registrar token: $e',
      );
    }
  }

  /// Eliminar un token de dispositivo del backend
  /// 
  /// [token] - Firebase Cloud Messaging token del dispositivo
  /// [authToken] - JWT de autenticación del usuario
  Future<ApiResponse<bool>> unregisterDeviceToken({
    required String token,
    required String authToken,
  }) async {
    try {
      final url = AppConfig.getApiUrl('notifications/device/$token');
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔔 ELIMINANDO TOKEN DE DISPOSITIVO');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 URL: $url');
      debugPrint('🎫 Token: ${token.substring(0, 20)}...');
      
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: authToken),
          )
          .timeout(AppConfig.defaultTimeout);
          
      debugPrint('📥 Respuesta: ${response.statusCode}');
      debugPrint('📄 Cuerpo: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(
          data: true,
          message: 'Token eliminado correctamente',
        );
      } else {
        return ApiResponse.error(
          message: 'Error al eliminar token: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ ERROR ELIMINANDO TOKEN');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      
      return ApiResponse.error(
        message: 'Error al eliminar token: $e',
      );
    }
  }

  /// Actualizar preferencias de notificaciones del usuario
  /// 
  /// [authToken] - JWT de autenticación del usuario
  /// [preferences] - Mapa con las preferencias de notificaciones
  Future<ApiResponse<bool>> updateNotificationPreferences({
    required String authToken,
    required Map<String, bool> preferences,
  }) async {
    try {
      final url = AppConfig.getApiUrl('notifications/preferences/');
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔔 ACTUALIZANDO PREFERENCIAS DE NOTIFICACIONES');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 URL: $url');
      debugPrint('🔧 Preferencias: $preferences');
      
      final response = await _client
          .put(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: authToken),
            body: json.encode({'preferences': preferences}),
          )
          .timeout(AppConfig.defaultTimeout);
          
      debugPrint('📥 Respuesta: ${response.statusCode}');
      debugPrint('📄 Cuerpo: ${response.body}');
      
      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: true,
          message: 'Preferencias actualizadas correctamente',
        );
      } else {
        return ApiResponse.error(
          message: 'Error al actualizar preferencias: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ ERROR ACTUALIZANDO PREFERENCIAS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      
      return ApiResponse.error(
        message: 'Error al actualizar preferencias: $e',
      );
    }
  }

  /// Obtener preferencias de notificaciones del usuario
  /// 
  /// [authToken] - JWT de autenticación del usuario
  Future<ApiResponse<Map<String, dynamic>>> getNotificationPreferences({
    required String authToken,
  }) async {
    try {
      final url = AppConfig.getApiUrl('notifications/preferences/');
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔔 OBTENIENDO PREFERENCIAS DE NOTIFICACIONES');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 URL: $url');
      
      final response = await _client
          .get(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: authToken),
          )
          .timeout(AppConfig.defaultTimeout);
          
      debugPrint('📥 Respuesta: ${response.statusCode}');
      debugPrint('📄 Cuerpo: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(
          data: data,
          message: 'Preferencias obtenidas correctamente',
        );
      } else {
        return ApiResponse.error(
          message: 'Error al obtener preferencias: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ ERROR OBTENIENDO PREFERENCIAS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      
      return ApiResponse.error(
        message: 'Error al obtener preferencias: $e',
      );
    }
  }

  /// Obtener historial de notificaciones del usuario
  /// 
  /// [authToken] - JWT de autenticación del usuario
  /// [page] - Número de página para paginación (opcional)
  /// [pageSize] - Tamaño de página para paginación (opcional)
  Future<ApiResponse<Map<String, dynamic>>> getNotificationHistory({
    required String authToken,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = AppConfig.getApiUrl('notifications/history/?page=$page&size=$pageSize');
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔔 OBTENIENDO HISTORIAL DE NOTIFICACIONES');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 URL: $url');
      debugPrint('📃 Página: $page, Tamaño: $pageSize');
      
      final response = await _client
          .get(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: authToken),
          )
          .timeout(AppConfig.defaultTimeout);
          
      debugPrint('📥 Respuesta: ${response.statusCode}');
      debugPrint('📄 Cuerpo: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(
          data: data,
          message: 'Historial obtenido correctamente',
        );
      } else {
        return ApiResponse.error(
          message: 'Error al obtener historial: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ ERROR OBTENIENDO HISTORIAL');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      
      return ApiResponse.error(
        message: 'Error al obtener historial: $e',
      );
    }
  }

  /// Marcar una notificación como leída
  /// 
  /// [notificationId] - ID de la notificación
  /// [authToken] - JWT de autenticación del usuario
  Future<ApiResponse<bool>> markNotificationAsRead({
    required String notificationId,
    required String authToken,
  }) async {
    try {
      final url = AppConfig.getApiUrl('notifications/$notificationId/read/');
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔔 MARCANDO NOTIFICACIÓN COMO LEÍDA');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 URL: $url');
      debugPrint('🔑 ID: $notificationId');
      
      final response = await _client
          .post(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: authToken),
          )
          .timeout(AppConfig.defaultTimeout);
          
      debugPrint('📥 Respuesta: ${response.statusCode}');
      debugPrint('📄 Cuerpo: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(
          data: true,
          message: 'Notificación marcada como leída correctamente',
        );
      } else {
        return ApiResponse.error(
          message: 'Error al marcar notificación como leída: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ ERROR MARCANDO NOTIFICACIÓN COMO LEÍDA');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      
      return ApiResponse.error(
        message: 'Error al marcar notificación como leída: $e',
      );
    }
  }

  /// Marcar todas las notificaciones como leídas
  /// 
  /// [authToken] - JWT de autenticación del usuario
  Future<ApiResponse<bool>> markAllNotificationsAsRead({
    required String authToken,
  }) async {
    try {
      final url = AppConfig.getApiUrl('notifications/read-all/');
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔔 MARCANDO TODAS LAS NOTIFICACIONES COMO LEÍDAS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 URL: $url');
      
      final response = await _client
          .post(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: authToken),
          )
          .timeout(AppConfig.defaultTimeout);
          
      debugPrint('📥 Respuesta: ${response.statusCode}');
      debugPrint('📄 Cuerpo: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(
          data: true,
          message: 'Todas las notificaciones marcadas como leídas correctamente',
        );
      } else {
        return ApiResponse.error(
          message: 'Error al marcar todas las notificaciones como leídas: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ ERROR MARCANDO TODAS LAS NOTIFICACIONES COMO LEÍDAS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      
      return ApiResponse.error(
        message: 'Error al marcar todas las notificaciones como leídas: $e',
      );
    }
  }

  /// Obtener el string de plataforma actual
  String _getPlatform() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    } else {
      return 'unknown';
    }
  }
}
