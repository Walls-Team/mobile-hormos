import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:get_it/get_it.dart';

/// Interceptor de tokens que maneja automáticamente los errores 401 (token expirado)
/// y reintenta las solicitudes después de refrescar el token
class TokenInterceptor {
  static final AuthService _authService = GetIt.instance<AuthService>();
  static final UserStorageService _storageService = GetIt.instance<UserStorageService>();
  
  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;
  
  /// Ejecuta una solicitud HTTP con manejo automático de token expirado
  /// Verifica proactivamente si el token está por expirar y lo renueva si es necesario
  /// Si aun así recibe un error 401, intenta refrescar el token y reintenta la solicitud
  /// 
  /// [requestFn] es una función que recibe un token y devuelve una Future<http.Response>
  static Future<http.Response> executeWithTokenRefresh(
    Future<http.Response> Function(String token) requestFn,
  ) async {
    try {
      // Obtener el token actual
      final token = await _storageService.getJWTToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token disponible');
      }
      
      // NUEVO: Verificar si el token está por expirar
      if (await _isTokenAboutToExpire(token)) {
        debugPrint('🔑 Token por expirar. Refrescando proactivamente...');
        final newToken = await _refreshToken();
        
        if (newToken.isNotEmpty) {
          debugPrint('✅ Token refrescado proactivamente');
          return await requestFn(newToken);
        }
      }
      
      // Ejecutar la solicitud con el token actual (o el nuevo si se refrescó)
      final response = await requestFn(token);
      
      // Si aún así da 401, intentar refrescar una vez más
      if (response.statusCode == 401) {
        debugPrint('🔑 Token expirado (401). Intentando refrescar token...');
        
        final newToken = await _refreshToken();
        
        if (newToken.isNotEmpty) {
          debugPrint('🔄 Reintentando solicitud con nuevo token...');
          return await requestFn(newToken);
        } else {
          throw Exception('No se pudo refrescar el token');
        }
      }
      
      return response;
    } catch (e) {
      debugPrint('❌ Error en executeWithTokenRefresh: $e');
      rethrow;
    }
  }
  
  /// Refresca el token de acceso
  /// Utiliza un singleton pattern para evitar múltiples refrescos simultáneos
  static Future<String> _refreshToken() async {
    try {
      // Si ya hay un proceso de refresco en curso, esperar a que termine
      if (_isRefreshing) {
        debugPrint('🔄 Refresco de token ya en curso, esperando...');
        final result = await _refreshCompleter!.future;
        if (result) {
          return (await _storageService.getJWTToken()) ?? '';
        } else {
          throw Exception('Falló el refresco de token anterior');
        }
      }
      
      // Iniciar proceso de refresco
      _isRefreshing = true;
      _refreshCompleter = Completer<bool>();
      
      debugPrint('🔄 Iniciando refresco de token...');
      final response = await _authService.refreshToken();
      
      if (response.success && response.data != null) {
        debugPrint('✅ Token refrescado exitosamente');
        _isRefreshing = false;
        _refreshCompleter!.complete(true);
        return response.data!.accessToken;
      } else {
        debugPrint('❌ Error al refrescar token: ${response.message}');
        _isRefreshing = false;
        _refreshCompleter!.complete(false);
        throw Exception('Error al refrescar token: ${response.message}');
      }
    } catch (e) {
      debugPrint('💥 Error en _refreshToken: $e');
      _isRefreshing = false;
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(false);
      }
      throw Exception('Error al refrescar token: $e');
    }
  }
  
  /// Verifica si un token JWT está por expirar (menos de 5 minutos de validez)
  static Future<bool> _isTokenAboutToExpire(String token) async {
    try {
      // Decodificar el token para obtener la fecha de expiración
      final parts = token.split('.');
      if (parts.length != 3) return true; // Si el formato es incorrecto, refrescar
      
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      
      if (payload['exp'] != null) {
        final expiration = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
        final now = DateTime.now();
        final timeToExpire = expiration.difference(now);
        
        // Si el token expira en menos de 5 minutos, refrescar
        final shouldRefresh = timeToExpire.inMinutes < 5;
        if (shouldRefresh) {
          debugPrint('⚠️ Token expira pronto: ${timeToExpire.inMinutes} minutos restantes');
        }
        return shouldRefresh;
      }
      
      return false; // Si no hay campo exp, asumir que no expira
    } catch (e) {
      debugPrint('⚠️ Error verificando expiración del token: $e');
      return false; // En caso de error, no refrescar proactivamente
    }
  }
}
