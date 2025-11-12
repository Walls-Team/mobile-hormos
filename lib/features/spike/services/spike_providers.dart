// lib/services/spike_api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:genius_hormo/core/api/api_helpers.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/core/config/app_config.dart';
import 'package:genius_hormo/features/auth/dto/login_dto.dart';
import 'package:genius_hormo/features/spike/dto/my_device_dto.dart';
import 'package:genius_hormo/features/spike/models/spike_auth.dart';
import 'package:genius_hormo/features/spike/models/spike_integration.dart';
import 'package:http/http.dart' as http;

/// Respuesta de la integración de dispositivo Spike
class SpikeDeviceIntegrationResponse {
  final String taskId;
  final String provider;

  SpikeDeviceIntegrationResponse({
    required this.taskId,
    required this.provider,
  });

  factory SpikeDeviceIntegrationResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('\n🔍 Parseando SpikeDeviceIntegrationResponse desde JSON:');
    debugPrint('📦 JSON recibido: $json');
    
    try {
      final taskId = json['task_id']?.toString() ?? '';
      final provider = json['provider']?.toString() ?? 'whoop';
      
      debugPrint('✅ Valores parseados:');
      debugPrint('   task_id: $taskId');
      debugPrint('   provider: $provider\n');
      
      return SpikeDeviceIntegrationResponse(
        taskId: taskId,
        provider: provider,
      );
    } catch (e) {
      debugPrint('❌ Error parseando SpikeDeviceIntegrationResponse: $e\n');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'provider': provider,
    };
  }

  @override
  String toString() => 'SpikeDeviceIntegrationResponse(taskId: $taskId, provider: $provider)';
}

/// Resultado del task de integración
class SpikeTaskResult {
  final String taskId;
  final String status;
  final SpikeIntegrationResult? result;

  SpikeTaskResult({
    required this.taskId,
    required this.status,
    this.result,
  });

  factory SpikeTaskResult.fromJson(Map<String, dynamic> json) {
    debugPrint('\n🔍 Parseando SpikeTaskResult desde JSON:');
    debugPrint('📦 JSON recibido: $json');
    
    try {
      final taskId = json['task_id']?.toString() ?? '';
      
      // Parse result first
      SpikeIntegrationResult? result;
      if (json['result'] != null && json['result'] is Map) {
        result = SpikeIntegrationResult.fromJson(json['result']);
      }
      
      // Determinar status basado en la presencia de result con data
      String status;
      if (result != null && result.data != null) {
        status = 'completed';
      } else {
        status = 'pending';
      }
      
      debugPrint('✅ Valores parseados:');
      debugPrint('   task_id: $taskId');
      debugPrint('   status: $status (inferido de result)');
      debugPrint('   has_result: ${result != null}');
      debugPrint('   has_data: ${result?.data != null}\n');
      
      return SpikeTaskResult(
        taskId: taskId,
        status: status,
        result: result,
      );
    } catch (e) {
      debugPrint('❌ Error parseando SpikeTaskResult: $e\n');
      rethrow;
    }
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
}

/// Resultado de la integración con spike_id y integration_url
class SpikeIntegrationResult {
  final String message;
  final SpikeIntegrationData? data;
  final String error;

  SpikeIntegrationResult({
    required this.message,
    this.data,
    required this.error,
  });

  factory SpikeIntegrationResult.fromJson(Map<String, dynamic> json) {
    try {
      final message = json['message']?.toString() ?? '';
      final error = json['error']?.toString() ?? '';
      
      SpikeIntegrationData? data;
      if (json['data'] != null && json['data'] is Map) {
        data = SpikeIntegrationData.fromJson(json['data']);
      }
      
      return SpikeIntegrationResult(
        message: message,
        data: data,
        error: error,
      );
    } catch (e) {
      debugPrint('❌ Error parseando SpikeIntegrationResult: $e');
      rethrow;
    }
  }
}

/// Datos de integración con spike_id, integration_url y provider
class SpikeIntegrationData {
  final int spikeId;
  final String integrationUrl;
  final String provider;

  SpikeIntegrationData({
    required this.spikeId,
    required this.integrationUrl,
    required this.provider,
  });

  factory SpikeIntegrationData.fromJson(Map<String, dynamic> json) {
    try {
      final spikeId = int.tryParse(json['spike_id']?.toString() ?? '0') ?? 0;
      final integrationUrl = json['integration_url']?.toString() ?? '';
      final provider = json['provider']?.toString() ?? 'whoop';
      
      debugPrint('📊 SpikeIntegrationData parseado:');
      debugPrint('   spike_id: $spikeId');
      debugPrint('   integration_url: ${integrationUrl.substring(0, integrationUrl.length > 50 ? 50 : integrationUrl.length)}...');
      debugPrint('   provider: $provider');
      
      return SpikeIntegrationData(
        spikeId: spikeId,
        integrationUrl: integrationUrl,
        provider: provider,
      );
    } catch (e) {
      debugPrint('❌ Error parseando SpikeIntegrationData: $e');
      rethrow;
    }
  }
}

class SpikeApiService {
  static const String _baseUrl = 'http://localhost:3000';
  final http.Client _client;

  SpikeApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> requestSpikeAccesToken({
    required String userId,
    required String token,
  }) async {
    final result = await executeRequest<HmacAuthResponse>(
      request: _client
          .post(
            Uri.parse('$_baseUrl/auth/hmac'),
            headers: _getHeaders(withAuth: true, token: token),
            body: json.encode({'userId': userId}),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: HmacAuthResponse.fromJson,
    );

    if (result.data != null && result.data?.accessToken != null) {
      return result.data!.accessToken;
    }

    throw Exception('error al obtener token auth/hmac');
  }

  Future<ProviderIntegrationInit> requestWhoopIntegration({
    required String userId,
    required String token,
  }) async {
    final spikeUri =
        'https://app-api.spikeapi.com/v3/providers/whoop/integration/init_url';

    try {
      final spikeAccessToken = await requestSpikeAccesToken(
        userId: userId,
        token: token,
      );

      final spikeRes = await http
          .get(
            Uri.parse(spikeUri),
            headers: {
              'Authorization': 'Bearer $spikeAccessToken',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      return ProviderIntegrationInit.fromJson(json.decode(spikeRes.body));

    } catch (e) {
      throw Exception('whoop integration failed ${e.toString()}');
    }
  }

  /// Iniciar el proceso de integración de un dispositivo Spike
  /// Endpoint: POST /v1/api/spike/add/
  /// Body: {"provider": "whoop"}
  /// Respuesta: {"task_id": "...", "provider": "whoop", "message": "..."}
  Future<ApiResponse<SpikeDeviceIntegrationResponse>> initiateDeviceIntegration({
    required String token,
    String provider = 'whoop',
  }) async {
    try {
      final url = AppConfig.getApiUrl('spike/add/');
      final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);
      
      final body = json.encode({
        'provider': provider,
      });

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🚀 SPIKE DEVICE INTEGRATION REQUEST');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 ENDPOINT: spike/add/');
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
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(AppConfig.defaultTimeout);

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📥 SPIKE DEVICE INTEGRATION RESPONSE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body:');
      debugPrint(response.body);
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // Aceptar status codes 200, 201 y 202 (Accepted)
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        debugPrint('\n📊 Respuesta parseada:');
        debugPrint('   message: ${responseData['message']}');
        debugPrint('   error: ${responseData['error']}');
        debugPrint('   data: ${responseData['data']}');
        
        // Verificar si hay error en la respuesta
        final error = responseData['error']?.toString() ?? '';
        if (error.isNotEmpty) {
          debugPrint('❌ Error en respuesta: $error');
          return ApiResponse.error(message: error);
        }

        // Parsear los datos - están en responseData['data']
        final data = responseData['data'];
        if (data == null) {
          debugPrint('❌ No hay datos en la respuesta');
          return ApiResponse.error(message: 'No hay datos en la respuesta');
        }
        
        final integrationData = SpikeDeviceIntegrationResponse.fromJson(data);

        debugPrint('\n✅ SPIKE DEVICE INTEGRATION EXITOSA');
        debugPrint('   📊 Status Code: ${response.statusCode}');
        debugPrint('   🎯 Task ID: ${integrationData.taskId}');
        debugPrint('   📱 Provider: ${integrationData.provider}');
        debugPrint('   📝 Message: ${responseData['message']}\n');

        return ApiResponse.success(
          message: responseData['message']?.toString() ?? 'Integración iniciada',
          data: integrationData,
        );
      } else {
        final errorMessage = 'Error ${response.statusCode}: ${response.body}';
        debugPrint('❌ $errorMessage');
        return ApiResponse.error(message: errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💥 ERROR EN SPIKE DEVICE INTEGRATION');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return ApiResponse.error(message: 'Error al conectar dispositivo: $e');
    }
  }

  /// Verificar el status de un task de integración
  /// Endpoint: GET /v1/api/spike/results/:taskID/
  Future<ApiResponse<SpikeTaskResult>> checkTaskStatus({
    required String token,
    required String taskId,
  }) async {
    try {
      final url = AppConfig.getApiUrl('spike/results/$taskId/');
      final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔍 CHECK TASK STATUS REQUEST');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 ENDPOINT: spike/results/$taskId/');
      debugPrint('🌐 FULL URL: $url');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final response = await _client
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.defaultTimeout);

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📥 TASK STATUS RESPONSE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body:');
      debugPrint(response.body);
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // Aceptar status codes 200 (OK) y 202 (Accepted/Pending)
      if (response.statusCode == 200 || response.statusCode == 202) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Parsear los datos - están en responseData['data']
        final data = responseData['data'];
        if (data == null) {
          debugPrint('❌ No hay datos en la respuesta');
          return ApiResponse.error(message: 'No hay datos en la respuesta');
        }
        
        final taskResult = SpikeTaskResult.fromJson(data);

        debugPrint('📊 Task parsado:');
        debugPrint('   Status Code: ${response.statusCode}');
        debugPrint('   Task Status: ${taskResult.status}');
        debugPrint('   Is Completed: ${taskResult.isCompleted}\n');

        return ApiResponse.success(
          message: responseData['message']?.toString() ?? 'Task status retrieved',
          data: taskResult,
        );
      } else {
        final errorMessage = 'Error ${response.statusCode}: ${response.body}';
        debugPrint('❌ $errorMessage');
        return ApiResponse.error(message: errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💥 ERROR EN CHECK TASK STATUS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return ApiResponse.error(message: 'Error al verificar status: $e');
    }
  }

  /// Hacer polling del task hasta obtener el integration_url
  /// Llama al endpoint múltiples veces con intervalos hasta que el task se complete
  Future<ApiResponse<SpikeIntegrationData>> pollTaskUntilCompleted({
    required String token,
    required String taskId,
    int maxAttempts = 3,
    Duration interval = const Duration(seconds: 3),
  }) async {
    debugPrint('\n🔄 INICIANDO POLLING DEL TASK');
    debugPrint('   Task ID: $taskId');
    debugPrint('   Max intentos: $maxAttempts');
    debugPrint('   Intervalo: ${interval.inSeconds}s\n');

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      debugPrint('🔄 Intento $attempt/$maxAttempts...');

      final statusResponse = await checkTaskStatus(token: token, taskId: taskId);

      if (!statusResponse.success || statusResponse.data == null) {
        debugPrint('❌ Error al obtener status: ${statusResponse.message}');
        
        if (attempt == maxAttempts) {
          return ApiResponse.error(
            message: 'No se pudo obtener el status del task después de $maxAttempts intentos',
          );
        }
        
        await Future.delayed(interval);
        continue;
      }

      final taskResult = statusResponse.data!;
      debugPrint('📊 Status actual: ${taskResult.status}');

      if (taskResult.isCompleted && taskResult.result?.data != null) {
        final integrationData = taskResult.result!.data!;
        
        debugPrint('\n✅ TASK COMPLETADO');
        debugPrint('   🎯 Spike ID: ${integrationData.spikeId}');
        debugPrint('   🔗 Integration URL obtenido');
        debugPrint('   📱 Provider: ${integrationData.provider}\n');

        return ApiResponse.success(
          message: 'Integration URL obtenido exitosamente',
          data: integrationData,
        );
      }

      if (attempt < maxAttempts) {
        debugPrint('⏳ Esperando ${interval.inSeconds}s antes del siguiente intento...\n');
        await Future.delayed(interval);
      }
    }

    return ApiResponse.error(
      message: 'El task no se completó después de $maxAttempts intentos',
    );
  }

  /// Obtener información del dispositivo conectado del usuario
  /// Endpoint: GET /v1/api/spike/my-device/
  Future<ApiResponse<MyDeviceResponse>> getMyDevice({
    required String token,
  }) async {
    try {
      final url = AppConfig.getApiUrl('spike/my-device/');
      final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📱 GET MY DEVICE REQUEST');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 ENDPOINT: spike/my-device/');
      debugPrint('🌐 FULL URL: $url');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final response = await _client
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.defaultTimeout);

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📥 MY DEVICE RESPONSE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body:');
      debugPrint(response.body);
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Pasar todo el responseData porque contiene {"data": {...}}
        final myDevice = MyDeviceResponse.fromJson(responseData);

        debugPrint('✅ MY DEVICE OBTENIDO');
        debugPrint('   Has Device: ${myDevice.hasDevice}');
        if (myDevice.device != null) {
          debugPrint('   Device ID: ${myDevice.device!.id}');
          debugPrint('   Spike ID Hash: ${myDevice.device!.spikeIdHash}');
          debugPrint('   Provider: ${myDevice.device!.provider}');
          debugPrint('   Is Active: ${myDevice.device!.isActive}');
          debugPrint('   Consent Given: ${myDevice.device!.consentGiven}');
        }
        debugPrint('');

        return ApiResponse.success(
          message: responseData['message']?.toString() ?? 'Device info retrieved',
          data: myDevice,
        );
      } else {
        final errorMessage = 'Error ${response.statusCode}: ${response.body}';
        debugPrint('❌ $errorMessage');
        return ApiResponse.error(message: errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💥 ERROR EN GET MY DEVICE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return ApiResponse.error(message: 'Error al obtener dispositivo: $e');
    }
  }

  /// Desconectar el dispositivo del usuario
  /// Endpoint: DELETE /v1/api/spike/delete/:spike_id/
  Future<ApiResponse<void>> disconnectDevice({
    required String token,
    required String spikeId,
  }) async {
    try {
      final url = AppConfig.getApiUrl('spike/delete/$spikeId/');
      final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔌 DISCONNECT DEVICE REQUEST');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 ENDPOINT: spike/delete/$spikeId/');
      debugPrint('🌐 FULL URL: $url');
      debugPrint('🆔 Spike ID: $spikeId');
      debugPrint('🔧 METHOD: DELETE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final response = await _client
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.defaultTimeout);

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📥 DISCONNECT DEVICE RESPONSE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body:');
      debugPrint(response.body);
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // 200: OK, 202: Accepted (async), 204: No Content
      if (response.statusCode == 200 || 
          response.statusCode == 202 || 
          response.statusCode == 204) {
        
        String message = 'Device disconnected successfully';
        String? taskId;
        
        if (response.statusCode == 204) {
          message = 'Device disconnected successfully';
        } else {
          final responseData = json.decode(response.body);
          message = responseData['message']?.toString() ?? 'Device disconnected';
          
          // Si es 202, es un proceso asíncrono
          if (response.statusCode == 202 && responseData['data']?['task_id'] != null) {
            taskId = responseData['data']['task_id'];
            debugPrint('⏳ Proceso asíncrono iniciado');
            debugPrint('   Task ID: $taskId');
          }
        }
        
        debugPrint('✅ DISPOSITIVO DESCONECTADO EXITOSAMENTE\n');

        return ApiResponse.success(
          message: message,
          data: null,
        );
      } else {
        final errorMessage = 'Error ${response.statusCode}: ${response.body}';
        debugPrint('❌ $errorMessage');
        return ApiResponse.error(message: errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💥 ERROR EN DISCONNECT DEVICE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return ApiResponse.error(message: 'Error al desconectar dispositivo: $e');
    }
  }

  /// Enviar consentimiento de autorización del dispositivo
  /// Endpoint: POST /v1/api/spike/consent-callback/
  Future<ApiResponse<void>> consentCallback({
    required String token,
    required bool consentGiven,
  }) async {
    try {
      final url = AppConfig.getApiUrl('spike/consent-callback/');
      final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);
      
      final body = json.encode({
        'consent_given': consentGiven,
      });

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ CONSENT CALLBACK REQUEST');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 ENDPOINT: spike/consent-callback/');
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
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(AppConfig.defaultTimeout);

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📥 CONSENT CALLBACK RESPONSE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body:');
      debugPrint(response.body);
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        debugPrint('✅ CONSENT ENVIADO EXITOSAMENTE');
        debugPrint('   📝 Message: ${responseData['message']}\n');

        return ApiResponse.success(
          message: responseData['message']?.toString() ?? 'Consent registered successfully',
          data: null,
        );
      } else {
        final errorMessage = 'Error ${response.statusCode}: ${response.body}';
        debugPrint('❌ $errorMessage');
        return ApiResponse.error(message: errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💥 ERROR EN CONSENT CALLBACK');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return ApiResponse.error(message: 'Error al enviar consent: $e');
    }
  }

  Map<String, String> _getHeaders({bool withAuth = false, String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
