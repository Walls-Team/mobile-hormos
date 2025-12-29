import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/core/config/app_config.dart';
import 'package:genius_hormo/features/settings/models/stripe_checkout_response.dart';
import 'package:http/http.dart' as http;

/// Servicio para interactuar con los endpoints de Stripe del backend
class StripeApiService {
  final http.Client _client;

  StripeApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Crea una sesión de checkout de Stripe para un plan específico
  /// 
  /// [authToken] - JWT de autenticación del usuario
  /// [planId] - ID del plan que se quiere comprar
  Future<ApiResponse<StripeCheckoutResponse>> createCheckoutSession({
    required String authToken,
    required int planId,
  }) async {
    try {
      final url = AppConfig.getApiUrl('stripe/checkout/');
      final uri = Uri.parse(url);
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💳 CREANDO SESIÓN DE CHECKOUT STRIPE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 URL: $uri');
      
      // Crear request con solo el ID del plan
      // Las URLs de redirección serán manejadas por el backend
      final request = CreateCheckoutSessionRequest(
        planId: planId,
      );
      
      final response = await _client.post(
        uri,
        headers: AppConfig.getCommonHeaders(withAuth: true, token: authToken),
        body: jsonEncode(request.toJson()),
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonData = jsonDecode(response.body);
          debugPrint('\n💳 RESPUESTA PARSEADA:');
          debugPrint('-----------------------------');
          if (jsonData['data'] != null) {
            debugPrint('Data encontrada: ${jsonData['data']}');
            debugPrint('URL en data: ${jsonData['data']['url']}');
            debugPrint('Session ID: ${jsonData['data']['session_id']}');
          } else {
            debugPrint('No se encontró objeto data en la respuesta');
          }
          
          final stripeResponse = StripeCheckoutResponse.fromJson(jsonData);
          
          if (stripeResponse.checkoutUrl == null) {
            return ApiResponse.error(
              message: 'No se pudo obtener la URL de checkout',
              error: 'URL de checkout no encontrada en la respuesta',
            );
          }
          
          debugPrint('\n💳 URL de checkout extraida: ${stripeResponse.checkoutUrl}');
          
          return ApiResponse.success(
            data: stripeResponse,
            message: stripeResponse.message ?? 'Sesión de checkout creada exitosamente',
          );
        } catch (e) {
          debugPrint('❌ Error parseando respuesta JSON: $e');
          return ApiResponse.error(
            message: 'Error al procesar la respuesta de checkout',
            error: e.toString(),
          );
        }
      } else {
        debugPrint('⚠️ Respuesta con error, status: ${response.statusCode}');
        try {
          final jsonData = jsonDecode(response.body);
          return ApiResponse.error(
            message: jsonData['message'] ?? 'No se pudo crear la sesión de checkout',
            error: jsonData['error'] ?? 'Error ${response.statusCode}',
          );
        } catch (e) {
          return ApiResponse.error(
            message: 'No se pudo crear la sesión de checkout',
            error: 'Error ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error creando sesión de checkout: $e');
      return ApiResponse.error(
        message: 'No se pudo crear la sesión de checkout',
        error: e.toString(),
      );
    }
  }
}
