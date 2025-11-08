// services/spike_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SpikeService {
  static const String _baseUrl = 'http://localhost:3000/v1/api'; // Misma URL base
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Método para obtener los dispositivos del usuario
  Future<Map<String, dynamic>> myDevice() async {
    try {
      // Obtener el token JWT almacenado
      final String? token = await _secureStorage.read(key: 'jwt_token');
      
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'error': 'No hay token de autenticación disponible',
        };
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/spike/my-device'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Incluir el token en el header
        },
      );

      print('My Device Response status: ${response.statusCode}');
      print('My Device Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Verificar si la respuesta es exitosa
        if (responseData['success'] == true) {
          return {
            'success': true,
            'data': responseData['data'] ?? responseData,
            'message': responseData['message'] ?? 'Dispositivos obtenidos exitosamente',
          };
        } else {
          return {
            'success': false,
            'error': responseData['message'] ?? 'Error al obtener los dispositivos',
          };
        }
      } else if (response.statusCode == 401) {
        // Token inválido o expirado
        return {
          'success': false,
          'error': 'Token de autenticación inválido o expirado',
          'unauthorized': true,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Error al obtener los dispositivos',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Error en myDevice: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Método auxiliar para verificar si hay un token disponible
  Future<bool> hasValidToken() async {
    try {
      final String? token = await _secureStorage.read(key: 'jwt_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Método para obtener el token (útil para debugging)
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }
}