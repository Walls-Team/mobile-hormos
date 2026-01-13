import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/core/config/app_config.dart';
import 'package:genius_hormo/features/settings/models/plan.dart';
import 'package:http/http.dart' as http;

/// Servicio para interactuar con los endpoints de planes del backend
class PlansApiService {
  final http.Client _client;

  PlansApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Obtener la lista de planes disponibles
  /// 
  /// [authToken] - JWT de autenticación del usuario
  /// [page] - Número de página para la paginación (opcional)
  /// [pageSize] - Cantidad de elementos por página (opcional)
  Future<ApiResponse<PlansResponse>> getPlans({
    required String authToken,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final url = AppConfig.getApiUrl('plans/');
      
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🛒 OBTENIENDO PLANES');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 URL: $uri');
      
      final response = await _client.get(
        uri,
        headers: AppConfig.getCommonHeaders(withAuth: true, token: authToken),
      );
      
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          
          // Para depuración
          debugPrint('JSON recibido: $jsonData');
          
          // Verificar si la API devuelve datos
          if (jsonData['data'] == null) {
            debugPrint('🚧 Datos nulos en la respuesta de la API');
            
            return ApiResponse.error(
              message: 'No se encontraron datos de planes en la respuesta',
              error: 'data es null',
            );
          }
          
          final plansResponse = PlansResponse.fromJson(jsonData);
          
          return ApiResponse.success(
            data: plansResponse,
            message: jsonData['message'] ?? 'Planes obtenidos exitosamente',
          );
        } catch (e) {
          debugPrint('❌ Error parseando respuesta JSON: $e');
          
          return ApiResponse.error(
            message: 'Error al procesar los datos de planes',
            error: e.toString(),
          );
        }
      } else {
        debugPrint('⚠️ Respuesta con error, status: ${response.statusCode}');
        try {
          final jsonData = jsonDecode(response.body);
          
          return ApiResponse.error(
            message: jsonData['message'] ?? 'No se pudieron obtener los planes',
            error: jsonData['error'] ?? 'Error ${response.statusCode}',
          );
        } catch (e) {
          // Si no podemos parsear la respuesta de error, retornar un mensaje genérico
          return ApiResponse.error(
            message: 'No se pudieron obtener los planes',
            error: 'Error ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error obteniendo planes: $e');
      
      return ApiResponse.error(
        message: 'No se pudieron obtener los planes',
        error: e.toString(),
      );
    }
  }

    /// Obtener el plan actual del usuario
  /// 
  /// [authToken] - JWT de autenticación del usuario
  Future<ApiResponse<Plan>> getCurrentPlan({
    required String authToken,
  }) async {
    try {
      // Usar el endpoint exacto que aparece en la imagen
      final endpoint = 'subscriptions/current';
      final url = AppConfig.getApiUrl(endpoint);
      final uri = Uri.parse(url);
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔍 CONSULTANDO PLAN ACTUAL');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 URL: $url');
      
      // Realizar la petición
      final response = await _client.get(
        uri,
        headers: AppConfig.getCommonHeaders(withAuth: true, token: authToken),
      );
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 RESPUESTA DE PLAN ACTUAL');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 Status Code: ${response.statusCode}');
      
      // Imprimir headers de la respuesta
      debugPrint('📤 Headers Enviados:');
      final headers = AppConfig.getCommonHeaders(withAuth: true, token: authToken);
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          debugPrint('   $key: Bearer ${authToken.substring(0, 20)}...');
        } else {
          debugPrint('   $key: $value');
        }
      });
      
      debugPrint('\n📄 RESPONSE BODY COMPLETO:');
      debugPrint('${response.body}');
      
      // Intentar parsear para mostrar en formato JSON
      try {
        final jsonData = jsonDecode(response.body);
        debugPrint('\n📄 RESPONSE BODY ESTRUCTURADO:');
        debugPrint('   Mensaje: ${jsonData['message'] ?? "N/A"}');
        debugPrint('   Error: ${jsonData['error'] ?? "Ninguno"}');
        
        if (jsonData['data'] != null) {
          final data = jsonData['data'];
          debugPrint('   Data:\n      ID: ${data['id'] ?? "N/A"}');
          debugPrint('      Título: ${data['title'] ?? "N/A"}');
          debugPrint('      Descripción: ${data['description'] ?? "N/A"}');
          debugPrint('      Precio: ${data['price'] ?? "N/A"}');
          debugPrint('      Estado: ${data['status'] ?? "N/A"}');
          debugPrint('      Activo: ${data['active'] ?? "N/A"}');
          if (data['features'] != null) {
            debugPrint('      Características: ${data['features']}');
          }
        } else {
          debugPrint('   Data: null');
        }
      } catch (e) {
        debugPrint('❌ Error parseando JSON: $e');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          
          // Verificar si la API devuelve datos
          if (jsonData['data'] == null) {
            debugPrint('⚠️ No hay datos del plan en la respuesta');
            
            return ApiResponse.error(
              message: 'No se encontraron datos del plan actual',
              error: 'data es null',
            );
          }
          
          final plan = Plan.fromJson(jsonData['data']);
          debugPrint('✅ Plan actual obtenido: ${plan.title} (ID: ${plan.id})');
          
          return ApiResponse.success(
            data: plan,
            message: jsonData['message'] ?? 'Plan actual obtenido exitosamente',
          );
        } catch (e) {
          debugPrint('❌ Error parseando respuesta JSON: $e');
          
          return ApiResponse.error(
            message: 'Error al procesar los datos del plan',
            error: e.toString(),
          );
        }
      } else {
        debugPrint('⚠️ Respuesta con error, status: ${response.statusCode}');
        try {
          final jsonData = jsonDecode(response.body);
          
          return ApiResponse.error(
            message: jsonData['message'] ?? 'No se pudo obtener el plan actual',
            error: jsonData['error'] ?? 'Error ${response.statusCode}',
          );
        } catch (e) {
          return ApiResponse.error(
            message: 'No se pudo obtener el plan actual',
            error: 'Error ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error obteniendo plan actual: $e');
      
      return ApiResponse.error(
        message: 'No se pudo obtener el plan actual',
        error: e.toString(),
      );
    }
  }
}
