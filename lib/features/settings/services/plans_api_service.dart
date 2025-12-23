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
}
