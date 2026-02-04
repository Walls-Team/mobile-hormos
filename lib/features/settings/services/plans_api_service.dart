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
    final endpoint = 'plans/';
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    final uri = Uri.parse(AppConfig.getApiUrl(endpoint)).replace(queryParameters: queryParams);
    final headers = AppConfig.getCommonHeaders(withAuth: true, token: authToken);
    
    try {
      // Log mínimo para depuración
      debugPrint('� Obteniendo planes: $uri');
      
      final response = await _client.get(uri, headers: headers);
      final statusCode = response.statusCode;
      
      // Solo log relevante del status code
      debugPrint('📊 Planes - Status Code: $statusCode');
      
      // Manejar la respuesta
      return _handlePlansResponse(response);
    } catch (e) {
      // Log único del error
      debugPrint('❌ Error obteniendo planes: $e');
      
      return ApiResponse.error(
        message: 'No se pudieron obtener los planes',
        error: e.toString(),
      );
    }
  }
  
  /// Método privado para procesar la respuesta de la lista de planes
  ApiResponse<PlansResponse> _handlePlansResponse(http.Response response) {
    try {
      final jsonData = jsonDecode(response.body);
      
      // Si es respuesta exitosa
      if (response.statusCode == 200) {
        if (jsonData['data'] == null) {
          return ApiResponse.error(
            message: 'No se encontraron datos de planes en la respuesta',
            error: 'Datos nulos en la respuesta',
          );
        }
        
        final plansResponse = PlansResponse.fromJson(jsonData);
        return ApiResponse.success(
          data: plansResponse,
          message: jsonData['message'] ?? 'Planes obtenidos exitosamente',
        );
      } 
      // Si hay error con datos en JSON
      else {
        return ApiResponse.error(
          message: jsonData['message'] ?? 'No se pudieron obtener los planes',
          error: jsonData['error'] ?? 'Error ${response.statusCode}',
        );
      }
    } 
    // Si hay error al parsear el JSON
    catch (e) {
      return ApiResponse.error(
        message: 'Error al procesar los datos de planes',
        error: 'Error ${response.statusCode}: ${e.toString()}',
      );
    }
  }

  /// Obtener el plan actual del usuario
  /// 
  /// [authToken] - JWT de autenticación del usuario
  Future<ApiResponse<Plan>> getCurrentPlan({
    required String authToken,
  }) async {
    final endpoint = 'subscriptions/current';
    final uri = Uri.parse(AppConfig.getApiUrl(endpoint));
    final headers = AppConfig.getCommonHeaders(withAuth: true, token: authToken);
    
    try {
      // Para depuración mínima
      debugPrint('🔍 Obteniendo plan actual: $uri');
      
      final response = await _client.get(uri, headers: headers);
      final statusCode = response.statusCode;
      
      // Solo log relevante del status code
      debugPrint('📊 Plan actual - Status Code: $statusCode');
      
      // Manejar la respuesta
      return _handleCurrentPlanResponse(response);
    } catch (e) {
      // Log único del error
      debugPrint('❌ Error obteniendo plan actual: $e');
      
      return ApiResponse.error(
        message: 'No se pudo obtener el plan actual',
        error: e.toString(),
      );
    }
  }
  
  /// Método privado para procesar la respuesta del plan actual
  ApiResponse<Plan> _handleCurrentPlanResponse(http.Response response) {
    try {
      final jsonData = jsonDecode(response.body);
      
      // Si es respuesta exitosa
      if (response.statusCode == 200) {
        if (jsonData['data'] == null) {
          return ApiResponse.error(
            message: 'No se encontraron datos del plan actual',
            error: 'Datos nulos en la respuesta',
          );
        }
        
        final plan = Plan.fromJson(jsonData['data']);
        return ApiResponse.success(
          data: plan,
          message: jsonData['message'] ?? 'Plan actual obtenido exitosamente',
        );
      } 
      // Si hay error con datos en JSON
      else {
        return ApiResponse.error(
          message: jsonData['message'] ?? 'No se pudo obtener el plan actual',
          error: jsonData['error'] ?? 'Error ${response.statusCode}',
        );
      }
    } 
    // Si hay error al parsear el JSON
    catch (e) {
      return ApiResponse.error(
        message: 'Error al procesar los datos del plan',
        error: 'Error ${response.statusCode}: ${e.toString()}',
      );
    }
  }
}
