// lib/services/spike_api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:genius_hormo/features/spike/models/spike_models.dart';

class SpikeApiService {
  static const String _baseUrl = 'http://localhost:3000';
  static const Duration _requestTimeout = Duration(seconds: 30);
  
  final UserStorageService _userStorageService;

  SpikeApiService(this._userStorageService);

  // ========== OPERACIONES DE API ==========
  
  /// Obtener dispositivos del usuario desde el servidor
  Future<DevicesResponse> getMyDevices() async {
    try {
      final String? token = await _userStorageService.getJWTToken();
      
      if (token == null || token.isEmpty) {
        return DevicesResponse.error(
          message: 'No hay token de autenticación disponible',
          unauthorized: true,
        );
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/spike/my-device'),
        headers: _buildHeaders(token),
      ).timeout(_requestTimeout);

      print('🔗 My Devices Response status: ${response.statusCode}');
      print('🔗 My Devices Response body: ${response.body}');

      return _handleDeviceResponse(response);
      
    } on TimeoutException {
      return DevicesResponse.error(
        message: 'Tiempo de espera agotado al obtener dispositivos',
      );
    } catch (e) {
      print('❌ Error en getMyDevices: $e');
      return DevicesResponse.error(
        message: 'Error de conexión: $e',
      );
    }
  }

  // ========== MÉTODOS AUXILIARES ==========
  
  Map<String, String> _buildHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  DevicesResponse _handleDeviceResponse(http.Response response) {
    // Verificar si la respuesta es HTML (error 404)
    if (_isHtmlResponse(response.body)) {
      return DevicesResponse.error(
        message: 'Endpoint no encontrado. Verifica la configuración del servidor.',
        statusCode: 404,
      );
    }

    final Map<String, dynamic> responseData;
    try {
      responseData = json.decode(response.body);
    } catch (e) {
      return DevicesResponse.error(
        message: 'Respuesta del servidor inválida',
        statusCode: 500,
      );
    }

    switch (response.statusCode) {
      case 200:
        return _handleSuccessResponse(responseData);
        
      case 401:
        return DevicesResponse.error(
          message: 'Token de autenticación inválido o expirado',
          unauthorized: true,
          statusCode: 401,
        );

      case 404:
        return DevicesResponse.error(
          message: responseData['message'] ?? 'No se encontró el dispositivo',
          statusCode: 404,
        );

      default:
        return DevicesResponse.error(
          message: responseData['message'] ?? 
                  responseData['error'] ??
                  'Error al obtener el dispositivo - Código: ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }

  DevicesResponse _handleSuccessResponse(Map<String, dynamic> responseData) {
    final String? error = responseData['error'];
    final bool hasError = error != null && error.isNotEmpty;

    if (!hasError) {
      final List<Device> devices = _processDeviceData(responseData);
      
      return DevicesResponse.success(
        message: responseData['message'] ?? 'Dispositivo obtenido exitosamente',
        devices: devices,
      );
    } else {
      return DevicesResponse.error(
        message: error ?? 'Error al obtener el dispositivo',
      );
    }
  }

  bool _isHtmlResponse(String body) {
    final trimmedBody = body.trim();
    return trimmedBody.startsWith('<!DOCTYPE html>') || 
           trimmedBody.startsWith('<html>');
  }

  List<Device> _processDeviceData(Map<String, dynamic> responseData) {
    final List<Device> devices = [];
    
    // Caso 1: Datos en responseData['data']
    if (responseData['data'] != null) {
      if (responseData['data'] is Map) {
        devices.add(Device.fromJson(responseData['data']));
      } else if (responseData['data'] is List) {
        for (final deviceData in responseData['data']) {
          devices.add(Device.fromJson(deviceData));
        }
      }
    } 
    // Caso 2: Datos directamente en la respuesta
    else if (responseData['id'] != null) {
      devices.add(Device.fromJson(responseData));
    }
    
    return devices;
  }

  
  Future<DevicesResponse> myDevice() async {
    return await getMyDevices();
  }
}